"""Kontrola statyczna, NIE kompilacja Swift ani wykonanie XCTest.

python -m pip install tree-sitter tree-sitter-swift openstep-parser Pillow
python Scripts/verify_project.py
"""
from pathlib import Path
import hashlib
import json
import re
import xml.etree.ElementTree as ET

from PIL import Image
from openstep_parser import OpenStepDecoder
from tree_sitter import Language, Parser
import tree_sitter_swift

ROOT = Path(__file__).resolve().parents[1]
errors = []
parser = Parser(Language(tree_sitter_swift.language()))
swift_files = sorted(ROOT.rglob("*.swift"))
for path in swift_files:
    source = path.read_bytes()
    tree = parser.parse(source)
    if tree.root_node.has_error:
        errors.append(f"Błąd składni Swift: {path.relative_to(ROOT)}")
    if re.search(rb"^(<<<<<<<|=======|>>>>>>>)", source, re.M):
        errors.append(f"Znaczniki konfliktu: {path.relative_to(ROOT)}")

project = OpenStepDecoder.ParseFromString((ROOT / "CookBook.xcodeproj/project.pbxproj").read_text(encoding="utf-8"))
objects = project["objects"]
targets = [value for value in objects.values() if value.get("isa") == "PBXNativeTarget"]
for target in targets:
    for group_id in target.get("fileSystemSynchronizedGroups", []):
        folder = ROOT / objects[group_id]["path"]
        if not folder.is_dir():
            errors.append(f"Brak katalogu targetu: {folder}")
    for field in ["buildConfigurationList", "productReference"]:
        if target[field] not in objects:
            errors.append(f"Brak obiektu {field}: {target['name']}")
    for phase in target.get("buildPhases", []):
        if phase not in objects:
            errors.append(f"Brak fazy budowania: {phase}")

scheme = ET.parse(ROOT / "CookBook.xcodeproj/xcshareddata/xcschemes/CookBook.xcscheme")
for reference in scheme.iter("BuildableReference"):
    if reference.attrib["BlueprintIdentifier"] not in objects:
        errors.append("Schemat wskazuje nieistniejący target")

assets = ROOT / "CookBook/Assets.xcassets"
asset_images = []
for metadata in assets.rglob("Contents.json"):
    content = json.loads(metadata.read_text(encoding="utf-8"))
    for entry in content.get("images", []):
        if "filename" not in entry:
            continue
        path = metadata.parent / entry["filename"]
        if not path.is_file():
            errors.append(f"Brak obrazu: {path.relative_to(ROOT)}")
            continue
        with Image.open(path) as image:
            size = image.size
            image.verify()
        if metadata.parent.suffix == ".appiconset" and size != (1024, 1024):
            errors.append(f"Niepoprawny wymiar ikony: {path.name} {size}")
        asset_images.append(path)

samples = (ROOT / "CookBook/Core/SampleRecipes.swift").read_text(encoding="utf-8")
photo_names = re.findall(r'imageName: "([^"]+)"', samples)
photo_hashes = []
for name in photo_names:
    directory = assets / f"{name}.imageset"
    metadata = directory / "Contents.json"
    if not metadata.exists():
        errors.append(f"Brak zdjęcia przepisu: {name}")
        continue
    entry = next(x for x in json.loads(metadata.read_text(encoding="utf-8"))["images"] if "filename" in x)
    photo_hashes.append(hashlib.sha256((directory / entry["filename"]).read_bytes()).hexdigest())
if len(set(photo_hashes)) < 15:
    errors.append("Mniej niż 15 różnych zdjęć przepisów")

for source in (ROOT / "CookBook").rglob("*.swift"):
    for name in re.findall(r'(?:Image|Color)\("([^"\\]+)"\)', source.read_text(encoding="utf-8")):
        if not (assets / f"{name}.imageset").is_dir() and not (assets / f"{name}.colorset").is_dir():
            errors.append(f"Brak zasobu: {name}")

unit_tests = sum(len(re.findall(r"func test\w+\(", x.read_text(encoding="utf-8"))) for x in (ROOT / "CookBookTests").glob("*.swift"))
ui_tests = sum(len(re.findall(r"func test\w+\(", x.read_text(encoding="utf-8"))) for x in (ROOT / "CookBookUITests").glob("*.swift"))
report = {
    "kind": "static_analysis_only",
    "swift_files_parsed": len(swift_files),
    "xcode_targets": [x["name"] for x in targets],
    "xcode_objects": len(objects),
    "asset_images_verified": len(asset_images),
    "unique_recipe_photos": len(set(photo_hashes)),
    "unit_and_integration_tests_defined": unit_tests,
    "ui_tests_defined": ui_tests,
    "xcode_build_executed": False,
    "xctest_executed": False,
    "ios_visual_verification_executed": False,
    "errors": errors,
    "source_sha256": {str(p.relative_to(ROOT)).replace("\\", "/"): hashlib.sha256(p.read_bytes()).hexdigest() for p in swift_files},
}
output = ROOT / "Docs/static-validation.json"
output.parent.mkdir(exist_ok=True)
output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")
print(json.dumps({k: v for k, v in report.items() if k != "source_sha256"}, indent=2, ensure_ascii=False))
raise SystemExit(bool(errors))
