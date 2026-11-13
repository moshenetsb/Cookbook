import Foundation

enum SampleRecipes {
    // Dane demonstracyjne w kodzie, bez bazy i bez plików audio/wideo.
    static func make() -> [Recipe] {
        let recipes: [Recipe] = [
            Recipe(
                title: "Orzo z cytryną i ziołami",
                summary: "Kremowe, świeże i gotowe w 25 minut.",
                category: .pasta, diet: .vegetarian, preparationTime: 25,
                ingredients: [
                    Ingredient("Orzo", 180, "g"),
                    Ingredient("Pomidorki koktajlowe", 250, "g"),
                    Ingredient("Szpinak baby", 50, "g"),
                    Ingredient("Feta", 60, "g"),
                    Ingredient("Cytryna", 1, "szt."),
                    Ingredient("Świeża bazylia", 1, "garść")
                ],
                steps: [
                    PreparationStep("Ugotuj orzo", "Ugotuj orzo według opakowania, al dente. Odcedź, zachowując ½ szklanki wody."),
                    PreparationStep("Przygotuj dodatki", "Przekrój pomidorki, opłucz szpinak. Zetrzyj skórkę cytryny i wyciśnij sok."),
                    PreparationStep("Podgrzej warzywa", "Duś pomidorki z odrobiną wody 4–5 minut. Dodaj szpinak i mieszaj, aż zwiędnie."),
                    PreparationStep("Połącz i podaj", "Dodaj orzo, fetę, skórkę i sok do smaku. Dolej wody z orzo, wymieszaj z bazylią.")
                ], imageName: "recipe_orzo", isFavorite: true
            ),
            Recipe(
                title: "Łosoś z cytryną", summary: "Pieczony łosoś z cytryną i koperkiem.",
                category: .fish, diet: .glutenFree, preparationTime: 30,
                ingredients: [
                    Ingredient("Filet z łososia", 300, "g"),
                    Ingredient("Cytryna", 1, "szt."),
                    Ingredient("Koperek", 1, "garść"),
                    Ingredient("Oliwa", 1, "łyżka"),
                    Ingredient("Sól i pieprz", nil, "do smaku")
                ],
                steps: [
                    PreparationStep("Rozgrzej piekarnik", "Ustaw 190°C i wyłóż naczynie papierem do pieczenia."),
                    PreparationStep("Dopraw rybę", "Skrop łososia oliwą i sokiem z cytryny. Dodaj koperek oraz przyprawy."),
                    PreparationStep("Upiecz", "Piecz około 15–18 minut, do całkowitego upieczenia ryby. Podaj od razu.")
                ],
                imageName: "recipe_salmon", isFavorite: true
            ),
            Recipe(
                title: "Miska z ciecierzycą", summary: "Kolorowe warzywa, ciecierzyca i sos jogurtowy.",
                category: .salad, diet: .vegetarian, preparationTime: 20,
                ingredients: [
                    Ingredient("Ciecierzyca ugotowana", 200, "g"),
                    Ingredient("Ogórek", 1, "szt."),
                    Ingredient("Pomidor", 2, "szt."),
                    Ingredient("Jogurt naturalny", 100, "g"),
                    Ingredient("Cytryna", 0.5, "szt.")
                ],
                steps: [
                    PreparationStep("Przygotuj ciecierzycę", "Opłucz i odsącz ugotowaną ciecierzycę."),
                    PreparationStep("Pokrój warzywa", "Umyj i pokrój ogórek oraz pomidory."),
                    PreparationStep("Połącz składniki", "Wymieszaj jogurt z sokiem z cytryny. Polej warzywa i ciecierzycę.")
                ],
                imageName: "recipe_chickpea", isFavorite: true
            ),
            Recipe(
                title: "Makaron pomidorowy", summary: "Prosty makaron z pomidorami i bazylią.",
                category: .pasta, diet: .vegetarian, preparationTime: 20,
                ingredients: [
                    Ingredient("Makaron", 200, "g"),
                    Ingredient("Pomidory", 250, "g"),
                    Ingredient("Czosnek", 2, "ząbki"),
                    Ingredient("Bazylia", 1, "garść"),
                    Ingredient("Oliwa", 1, "łyżka")
                ],
                steps: [
                    PreparationStep("Ugotuj makaron", "Ugotuj makaron zgodnie z instrukcją na opakowaniu."),
                    PreparationStep("Przygotuj sos", "Podsmaż czosnek na oliwie. Dodaj pomidory i duś 10 minut."),
                    PreparationStep("Podaj", "Połącz makaron z sosem i świeżą bazylią.")
                ], imageName: "recipe_tomato_pasta"
            ),
            Recipe(
                title: "Curry warzywne", summary: "Łagodne curry z ciecierzycą i mlekiem kokosowym.",
                diet: .vegan, preparationTime: 35, difficulty: .medium, servings: 3,
                ingredients: [
                    Ingredient("Ciecierzyca ugotowana", 200, "g"),
                    Ingredient("Marchew", 1, "szt."),
                    Ingredient("Cukinia", 1, "szt."),
                    Ingredient("Mleko kokosowe", 200, "ml"),
                    Ingredient("Pasta curry", 2, "łyżeczki"),
                    Ingredient("Ryż", 180, "g")
                ],
                steps: [
                    PreparationStep("Przygotuj warzywa", "Umyj i pokrój marchew oraz cukinię."),
                    PreparationStep("Ugotuj curry", "Podgrzej pastę curry, dodaj warzywa, ciecierzycę i mleko kokosowe. Duś 15 minut."),
                    PreparationStep("Podaj z ryżem", "Ugotuj ryż według opakowania. Rozłóż curry na porcje.")
                ], imageName: "recipe_vegetable_curry"
            ),
            Recipe(
                title: "Placuszki", summary: "Puszyste placuszki na słodkie śniadanie.",
                category: .breakfast, diet: .vegetarian, preparationTime: 20,
                ingredients: [
                    Ingredient("Jajko", 1, "szt."),
                    Ingredient("Mleko", 150, "ml"),
                    Ingredient("Mąka", 150, "g"),
                    Ingredient("Proszek do pieczenia", 1, "łyżeczka"),
                    Ingredient("Olej", 1, "łyżka")
                ],
                steps: [
                    PreparationStep("Wymieszaj ciasto", "Połącz mleko, jajko, mąkę i proszek do pieczenia."),
                    PreparationStep("Usmaż placuszki", "Nakładaj małe porcje na patelnię posmarowaną olejem. Smaż z obu stron na złoty kolor.")
                ], imageName: "recipe_pancakes"
            ),
            Recipe(
                title: "Tost z awokado", summary: "Chrupiące pieczywo i kremowe awokado.",
                category: .breakfast, diet: .vegan, preparationTime: 10, servings: 1,
                ingredients: [
                    Ingredient("Chleb", 2, "kromki"),
                    Ingredient("Awokado", 1, "szt."),
                    Ingredient("Pomidor", 1, "szt."),
                    Ingredient("Limonka", 0.5, "szt."),
                    Ingredient("Płatki chili", nil, "do smaku")
                ],
                steps: [
                    PreparationStep("Podpiecz pieczywo", "Przygotuj chrupiące grzanki w tosterze."),
                    PreparationStep("Przygotuj pastę", "Rozgnieć awokado z sokiem z limonki."),
                    PreparationStep("Ułóż dodatki", "Rozsmaruj pastę na chlebie. Dodaj pomidor i chili.")
                ], imageName: "recipe_avocado_toast"
            ),
            Recipe(
                title: "Kremowa zupa", summary: "Delikatny krem z dyni ze śmietanką.",
                category: .soup, diet: .vegetarian, preparationTime: 35, servings: 4,
                ingredients: [
                    Ingredient("Dynia", 500, "g"),
                    Ingredient("Cebula", 1, "szt."),
                    Ingredient("Bulion warzywny", 700, "ml"),
                    Ingredient("Śmietanka", 100, "ml"),
                    Ingredient("Oliwa", 1, "łyżka")
                ],
                steps: [
                    PreparationStep("Podsmaż warzywa", "Pokrój dynię i cebulę, podsmaż na oliwie."),
                    PreparationStep("Ugotuj", "Zalej bulionem. Gotuj, aż dynia zmięknie."),
                    PreparationStep("Zblenduj", "Zmiksuj na krem, dodaj śmietankę i dopraw.")
                ], imageName: "recipe_creamy_soup"
            ),
            Recipe(
                title: "Wrap z kurczakiem", summary: "Tortilla z kurczakiem i chrupiącymi warzywami.",
                preparationTime: 25,
                ingredients: [
                    Ingredient("Tortilla", 2, "szt."),
                    Ingredient("Pierś z kurczaka", 200, "g"),
                    Ingredient("Sałata", 4, "liście"),
                    Ingredient("Pomidor", 1, "szt."),
                    Ingredient("Sos jogurtowy", 2, "łyżki")
                ],
                steps: [
                    PreparationStep("Usmaż kurczaka", "Pokrój i dopraw kurczaka. Smaż, aż będzie całkowicie gotowy w środku."),
                    PreparationStep("Przygotuj warzywa", "Umyj sałatę i pokrój pomidor."),
                    PreparationStep("Zawiń", "Ułóż składniki na tortilli, dodaj sos i zawiń ciasno.")
                ], imageName: "recipe_chicken_wrap"
            ),
            Recipe(
                title: "Risotto", summary: "Kremowy ryż z pieczarkami i parmezanem.",
                diet: .vegetarian, preparationTime: 35, difficulty: .medium,
                ingredients: [
                    Ingredient("Ryż arborio", 180, "g"),
                    Ingredient("Bulion warzywny", 700, "ml"),
                    Ingredient("Pieczarki", 150, "g"),
                    Ingredient("Cebula", 1, "szt."),
                    Ingredient("Parmezan", 40, "g"),
                    Ingredient("Masło", 1, "łyżka")
                ],
                steps: [
                    PreparationStep("Podsmaż dodatki", "Zeszklij cebulę na maśle. Dodaj pieczarki, następnie ryż."),
                    PreparationStep("Dolewaj bulion", "Dodawaj po chochelce gorącego bulionu. Mieszaj i gotuj do miękkości."),
                    PreparationStep("Wykończ danie", "Wymieszaj z parmezanem. Podawaj od razu.")
                ], imageName: "recipe_risotto"
            ),
            Recipe(
                title: "Pieczone ziemniaki", summary: "Złociste ziemniaki z oliwą i ziołami.",
                category: .side, diet: .vegan, preparationTime: 40, servings: 3,
                ingredients: [
                    Ingredient("Ziemniaki", 600, "g"),
                    Ingredient("Oliwa", 2, "łyżki"),
                    Ingredient("Rozmaryn", 1, "łyżeczka"),
                    Ingredient("Papryka słodka", 1, "łyżeczka")
                ],
                steps: [
                    PreparationStep("Pokrój", "Umyj ziemniaki i pokrój w kawałki podobnej wielkości."),
                    PreparationStep("Dopraw", "Wymieszaj z oliwą, rozmarynem i papryką."),
                    PreparationStep("Upiecz", "Piecz 30–35 minut w 200°C, obracając w połowie czasu.")
                ], imageName: "recipe_baked_potatoes"
            ),
            Recipe(
                title: "Szakszuka", summary: "Jajka w aromatycznym sosie pomidorowym.",
                category: .breakfast, diet: .vegetarian, preparationTime: 25, difficulty: .medium,
                ingredients: [
                    Ingredient("Jajka", 3, "szt."),
                    Ingredient("Pomidory", 400, "g"),
                    Ingredient("Papryka", 1, "szt."),
                    Ingredient("Cebula", 1, "szt."),
                    Ingredient("Kumin", 1, "łyżeczka"),
                    Ingredient("Oliwa", 1, "łyżka")
                ],
                steps: [
                    PreparationStep("Podsmaż warzywa", "Podsmaż cebulę i pokrojoną paprykę na oliwie."),
                    PreparationStep("Przygotuj sos", "Dodaj pomidory i kumin. Duś 10 minut."),
                    PreparationStep("Dodaj jajka", "Zrób wgłębienia, wbij jajka. Duś pod przykryciem do ścięcia białek.")
                ], imageName: "recipe_shakshuka"
            ),
            Recipe(
                title: "Owsianka jagodowa", summary: "Ciepła owsianka z jagodami i orzechami.",
                category: .breakfast, diet: .vegetarian, preparationTime: 10, servings: 1,
                ingredients: [
                    Ingredient("Płatki owsiane", 50, "g"),
                    Ingredient("Mleko", 200, "ml"),
                    Ingredient("Jagody", 60, "g"),
                    Ingredient("Orzechy", 15, "g")
                ],
                steps: [
                    PreparationStep("Ugotuj płatki", "Gotuj płatki w mleku przez kilka minut, mieszając."),
                    PreparationStep("Dodaj owoce", "Przełóż do miski, dodaj jagody i posiekane orzechy.")
                ], imageName: "recipe_berry_oatmeal"
            ),
            Recipe(
                title: "Tofu z warzywami", summary: "Smażone tofu z warzywami i sosem sojowym.",
                diet: .vegan, preparationTime: 25, difficulty: .medium,
                ingredients: [
                    Ingredient("Tofu", 200, "g"),
                    Ingredient("Papryka", 1, "szt."),
                    Ingredient("Marchew", 1, "szt."),
                    Ingredient("Sos sojowy", 2, "łyżki"),
                    Ingredient("Olej", 1, "łyżka")
                ],
                steps: [
                    PreparationStep("Przygotuj tofu", "Osusz tofu i pokrój je w kostkę."),
                    PreparationStep("Obsmaż", "Smaż tofu na rozgrzanym oleju na złoty kolor."),
                    PreparationStep("Dodaj warzywa", "Dodaj pokrojone warzywa i sos sojowy. Smaż kilka minut, mieszając.")
                ], imageName: "recipe_tofu_stirfry"
            ),
            Recipe(
                title: "Jabłkowa kruszonka", summary: "Ciepłe jabłka pod maślaną kruszonką.",
                category: .dessert, diet: .vegetarian, preparationTime: 40, servings: 4,
                ingredients: [
                    Ingredient("Jabłka", 3, "szt."),
                    Ingredient("Mąka", 100, "g"),
                    Ingredient("Masło", 70, "g"),
                    Ingredient("Cukier", 50, "g"),
                    Ingredient("Cynamon", 1, "łyżeczka")
                ],
                steps: [
                    PreparationStep("Przygotuj jabłka", "Pokrój jabłka, wymieszaj z cynamonem i włóż do naczynia."),
                    PreparationStep("Zrób kruszonkę", "Rozetrzyj palcami mąkę, masło i cukier."),
                    PreparationStep("Upiecz", "Posyp jabłka kruszonką. Piecz około 25 minut w 180°C.")
                ], imageName: "recipe_apple_crumble"
            )
        ]
        return recipes.enumerated().map { index, recipe in
            var recipe = recipe
            recipe.createdAt = Date(timeIntervalSince1970: 1_790_000_000 - Double(index * 86_400))
            return recipe
        }
    }
}
