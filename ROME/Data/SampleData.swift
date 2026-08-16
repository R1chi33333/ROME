//
//  SampleData.swift
//  ROME
//
//  Static catalogue standing in for a real product database.
//
//  Product names are deliberately short — each one is rendered as the text of
//  a `PlaceholderThumbnail` where a photo would normally go, so anything longer
//  than about three words stops being readable at card size.
//

import Foundation

enum SampleData {

    // MARK: - Pets

    static let pets: [Pet] = [
        Pet(
            name: "Mochi",
            species: .cat,
            breed: "British Shorthair",
            weightKg: 4.6,
            birthday: Calendar.current.date(byAdding: .year, value: -3, to: .now),
            isNeutered: true,
            notes: "Prefers wet food in the evening. Slightly overweight — vet suggested portion control."
        ),
        Pet(
            name: "Biscuit",
            species: .dog,
            breed: "Golden Retriever",
            weightKg: 28.4,
            birthday: Calendar.current.date(byAdding: .year, value: -5, to: .now),
            isNeutered: true,
            notes: "Allergic to chicken. Needs joint support."
        ),
        Pet(
            name: "Sputnik",
            species: .reptile,
            breed: "Leopard Gecko",
            weightKg: 0.06,
            birthday: Calendar.current.date(byAdding: .year, value: -1, to: .now),
            isNeutered: false,
            notes: "Basking side should sit at 32°C."
        )
    ]

    // MARK: - Products

    static let products: [Product] = dog + cat + reptile + amphibian + bird + fish + smallPet

    /// The shop home shows these. Picked to spread across species rather than
    /// to be the highest rated.
    static var featured: [Product] {
        let names = [
            "Adult Dog Food", "Feather Wand", "Heat Lamp", "Terrarium Moss",
            "Parrot Seed Mix", "Aquarium Filter", "Timothy Hay", "Dental Chews"
        ]
        return names.compactMap { name in products.first { $0.name == name } }
    }

    // MARK: - Dog

    private static let dog: [Product] = [
        Product(
            name: "Adult Dog Food",
            species: [.dog], category: .food, price: 42.00, rating: 4.7, reviewCount: 1284,
            summary: "Complete dry food for adult dogs, with salmon as the single animal protein. No chicken, wheat or soy.",
            variants: ["2 kg", "7 kg", "12 kg"]
        ),
        Product(
            name: "Puppy Dry Food",
            species: [.dog], category: .food, price: 38.50, rating: 4.8, reviewCount: 642,
            summary: "Smaller kibble and higher fat content for dogs under twelve months.",
            variants: ["1.5 kg", "5 kg"]
        ),
        Product(
            name: "Dental Chews",
            species: [.dog], category: .treats, price: 16.99, rating: 4.5, reviewCount: 2103,
            summary: "Textured chews that scrape plaque as the dog works through them. One a day.",
            variants: ["Small", "Medium", "Large"]
        ),
        Product(
            name: "Rope Tug Toy",
            species: [.dog], category: .toys, price: 12.00, rating: 4.4, reviewCount: 517,
            summary: "Braided cotton rope for two-player tug. Frays safely rather than splintering.",
            variants: ["Medium", "Large"]
        ),
        Product(
            name: "Squeaky Duck",
            species: [.dog], category: .toys, price: 9.50, rating: 4.2, reviewCount: 388,
            summary: "Soft plush with a replaceable squeaker chamber.",
            variants: []
        ),
        Product(
            name: "Oatmeal Shampoo",
            species: [.dog], category: .grooming, price: 14.75, rating: 4.6, reviewCount: 731,
            summary: "Soap-free wash for itchy or sensitive skin. Rinses out clean.",
            variants: ["250 ml", "500 ml"]
        ),
        Product(
            name: "Nail Clippers",
            species: [.dog, .cat], category: .grooming, price: 11.20, rating: 4.3, reviewCount: 295,
            summary: "Stainless steel blades with a quick-guard to stop you cutting too far.",
            variants: []
        ),
        Product(
            name: "Joint Supplement",
            species: [.dog], category: .health, price: 29.99, rating: 4.6, reviewCount: 884,
            summary: "Glucosamine and green-lipped mussel chews for older or large-breed dogs.",
            variants: ["60 chews", "120 chews"]
        ),
        Product(
            name: "Leather Leash",
            species: [.dog], category: .accessories, price: 34.00, rating: 4.9, reviewCount: 412,
            summary: "Full-grain leather with a brass trigger clip. Softens with use.",
            variants: ["120 cm", "180 cm"]
        ),
        Product(
            name: "Steel Bowl",
            species: [.dog, .cat], category: .accessories, price: 18.00, rating: 4.5, reviewCount: 623,
            summary: "Weighted stainless bowl with a silicone base ring so it stays put.",
            variants: ["Small", "Large"]
        )
    ]

    // MARK: - Cat

    private static let cat: [Product] = [
        Product(
            name: "Adult Cat Food",
            species: [.cat], category: .food, price: 36.00, rating: 4.6, reviewCount: 1547,
            summary: "High-protein dry food with a reduced carbohydrate load for indoor cats.",
            variants: ["1.5 kg", "4 kg", "8 kg"]
        ),
        Product(
            name: "Kitten Wet Food",
            species: [.cat], category: .food, price: 24.50, rating: 4.7, reviewCount: 508,
            summary: "Twelve pouches of finely minced poultry in gravy, sized for kittens.",
            variants: ["12 pouches", "24 pouches"]
        ),
        Product(
            name: "Salmon Treats",
            species: [.cat], category: .treats, price: 8.99, rating: 4.4, reviewCount: 976,
            summary: "Freeze-dried salmon, one ingredient, no binders.",
            variants: []
        ),
        Product(
            name: "Feather Wand",
            species: [.cat], category: .toys, price: 10.50, rating: 4.8, reviewCount: 1832,
            summary: "Wire wand with a replaceable feather lure. The one toy most cats stay interested in.",
            variants: []
        ),
        Product(
            name: "Catnip Mouse",
            species: [.cat], category: .toys, price: 6.00, rating: 4.1, reviewCount: 744,
            summary: "Felt mouse with a refillable catnip pocket.",
            variants: ["Single", "Pack of 3"]
        ),
        Product(
            name: "Deshedding Brush",
            species: [.cat], category: .grooming, price: 19.99, rating: 4.7, reviewCount: 1105,
            summary: "Fine stainless teeth that pull loose undercoat without cutting guard hairs.",
            variants: ["Short hair", "Long hair"]
        ),
        Product(
            name: "Hairball Paste",
            species: [.cat], category: .health, price: 13.40, rating: 4.2, reviewCount: 389,
            summary: "Malt paste that helps swallowed hair pass through rather than come back up.",
            variants: []
        ),
        Product(
            name: "Scratching Post",
            species: [.cat], category: .accessories, price: 46.00, rating: 4.5, reviewCount: 667,
            summary: "Sisal-wrapped column on a weighted base, tall enough for a full stretch.",
            variants: ["60 cm", "90 cm"]
        ),
        Product(
            name: "Ceramic Bowl",
            species: [.cat], category: .accessories, price: 15.00, rating: 4.4, reviewCount: 421,
            summary: "Shallow and wide, so whiskers stay clear of the sides.",
            variants: []
        )
    ]

    // MARK: - Reptile

    private static let reptile: [Product] = [
        Product(
            name: "Reptile Pellets",
            species: [.reptile], category: .food, price: 17.99, rating: 4.3, reviewCount: 236,
            summary: "Balanced pellets for omnivorous reptiles. Soak before feeding.",
            variants: ["250 g", "600 g"]
        ),
        Product(
            name: "Live Crickets",
            species: [.reptile, .amphibian], category: .food, price: 12.50, rating: 4.0, reviewCount: 512,
            summary: "Gut-loaded crickets shipped live. Choose the size closest to the gap between your animal's eyes.",
            variants: ["Small", "Medium", "Large"]
        ),
        Product(
            name: "Heat Lamp",
            species: [.reptile], category: .habitat, price: 32.00, rating: 4.6, reviewCount: 743,
            summary: "Ceramic basking lamp with a dimmable fitting. Pair with a thermostat.",
            variants: ["50 W", "100 W", "150 W"]
        ),
        Product(
            name: "Terrarium Substrate",
            species: [.reptile], category: .habitat, price: 21.00, rating: 4.4, reviewCount: 318,
            summary: "Coconut fibre bedding that holds a burrow and stays low-dust.",
            variants: ["5 L", "10 L"]
        ),
        Product(
            name: "Basking Rock",
            species: [.reptile], category: .habitat, price: 24.99, rating: 4.2, reviewCount: 174,
            summary: "Resin ledge shaped for a lamp to warm evenly, with a hide underneath.",
            variants: []
        ),
        Product(
            name: "Calcium Powder",
            species: [.reptile, .amphibian], category: .health, price: 9.99, rating: 4.7, reviewCount: 891,
            summary: "Calcium with D3 for dusting feeder insects. Prevents metabolic bone disease.",
            variants: ["With D3", "Without D3"]
        ),
        Product(
            name: "Feeding Tongs",
            species: [.reptile], category: .accessories, price: 7.50, rating: 4.5, reviewCount: 263,
            summary: "Bamboo tongs with rounded tips, so you keep fingers out of the strike zone.",
            variants: []
        )
    ]

    // MARK: - Amphibian

    private static let amphibian: [Product] = [
        Product(
            name: "Amphibian Pellets",
            species: [.amphibian], category: .food, price: 15.50, rating: 4.1, reviewCount: 142,
            summary: "Sinking pellets for aquatic frogs and newts.",
            variants: ["100 g", "300 g"]
        ),
        Product(
            name: "Frozen Bloodworms",
            species: [.amphibian, .fish], category: .food, price: 11.00, rating: 4.5, reviewCount: 604,
            summary: "Flat-frozen blister packs. Thaw one cube in tank water before feeding.",
            variants: []
        ),
        Product(
            name: "Terrarium Moss",
            species: [.amphibian], category: .habitat, price: 13.99, rating: 4.6, reviewCount: 387,
            summary: "Compressed sphagnum that expands in water and holds humidity for days.",
            variants: ["Brick", "Loose 2 L"]
        ),
        Product(
            name: "Misting System",
            species: [.amphibian], category: .habitat, price: 68.00, rating: 4.4, reviewCount: 219,
            summary: "Pump and nozzle kit on a timer, for species that need humidity above 70%.",
            variants: ["Single nozzle", "Dual nozzle"]
        ),
        Product(
            name: "Hide Cave",
            species: [.amphibian, .reptile], category: .habitat, price: 16.00, rating: 4.3, reviewCount: 296,
            summary: "Cork-look resin hide with a wide mouth and a damp chamber inside.",
            variants: ["Small", "Medium"]
        ),
        Product(
            name: "Water Conditioner",
            species: [.amphibian, .fish], category: .health, price: 10.75, rating: 4.8, reviewCount: 1420,
            summary: "Neutralises chlorine and chloramine instantly. Essential for amphibian skin.",
            variants: ["100 ml", "500 ml"]
        ),
        Product(
            name: "Humidity Gauge",
            species: [.amphibian], category: .accessories, price: 12.99, rating: 4.2, reviewCount: 188,
            summary: "Digital probe reading temperature and humidity, with a suction mount.",
            variants: []
        )
    ]

    // MARK: - Bird

    private static let bird: [Product] = [
        Product(
            name: "Parrot Seed Mix",
            species: [.bird], category: .food, price: 22.00, rating: 4.4, reviewCount: 533,
            summary: "Sunflower-light mix with more pellets than seed, to avoid selective feeding.",
            variants: ["1 kg", "3 kg"]
        ),
        Product(
            name: "Millet Spray",
            species: [.bird], category: .treats, price: 7.99, rating: 4.7, reviewCount: 812,
            summary: "Whole sprays on the stalk. Good for foraging as well as eating.",
            variants: ["6 sprays", "12 sprays"]
        ),
        Product(
            name: "Bird Swing",
            species: [.bird], category: .toys, price: 14.50, rating: 4.3, reviewCount: 267,
            summary: "Untreated hardwood swing on cotton rope, sized for a small parrot.",
            variants: []
        ),
        Product(
            name: "Foraging Ball",
            species: [.bird], category: .toys, price: 18.00, rating: 4.5, reviewCount: 341,
            summary: "Wicker ball you hide treats inside. Takes a bird a good half hour.",
            variants: []
        ),
        Product(
            name: "Wooden Perch",
            species: [.bird], category: .habitat, price: 16.75, rating: 4.6, reviewCount: 448,
            summary: "Natural branch of uneven diameter, which keeps feet from stiffening.",
            variants: ["25 cm", "40 cm"]
        ),
        Product(
            name: "Cuttlebone",
            species: [.bird], category: .health, price: 5.50, rating: 4.6, reviewCount: 1067,
            summary: "Calcium source birds work down themselves. Clip to the cage bars.",
            variants: ["Pack of 2", "Pack of 5"]
        )
    ]

    // MARK: - Fish

    private static let fish: [Product] = [
        Product(
            name: "Tropical Flakes",
            species: [.fish], category: .food, price: 9.99, rating: 4.5, reviewCount: 1893,
            summary: "Everyday flake for community tropicals. Feed what they clear in two minutes.",
            variants: ["50 g", "200 g"]
        ),
        Product(
            name: "Algae Wafers",
            species: [.fish], category: .food, price: 11.50, rating: 4.6, reviewCount: 724,
            summary: "Sinking wafers for plecos and other bottom feeders.",
            variants: []
        ),
        Product(
            name: "Aquarium Filter",
            species: [.fish], category: .habitat, price: 54.00, rating: 4.7, reviewCount: 966,
            summary: "External canister rated to 200 litres, with room for biological media.",
            variants: ["100 L", "200 L", "400 L"]
        ),
        Product(
            name: "Aquarium Heater",
            species: [.fish], category: .habitat, price: 27.99, rating: 4.3, reviewCount: 611,
            summary: "Submersible heater with an external thermostat dial and a shatter guard.",
            variants: ["50 W", "100 W", "200 W"]
        ),
        Product(
            name: "Gravel Substrate",
            species: [.fish], category: .habitat, price: 19.00, rating: 4.2, reviewCount: 355,
            summary: "Rounded, inert gravel that will not alter water hardness.",
            variants: ["5 kg", "10 kg"]
        ),
        Product(
            name: "Water Test Kit",
            species: [.fish], category: .health, price: 33.50, rating: 4.8, reviewCount: 1502,
            summary: "Liquid reagent tests for ammonia, nitrite, nitrate and pH. Far more accurate than strips.",
            variants: []
        ),
        Product(
            name: "Fish Net",
            species: [.fish], category: .accessories, price: 6.50, rating: 4.1, reviewCount: 289,
            summary: "Soft fine mesh that will not catch fins.",
            variants: ["Small", "Medium"]
        )
    ]

    // MARK: - Small pets

    private static let smallPet: [Product] = [
        Product(
            name: "Timothy Hay",
            species: [.smallPet], category: .food, price: 20.00, rating: 4.8, reviewCount: 2241,
            summary: "Second-cut timothy, the bulk of a rabbit or guinea pig's diet. Should be available at all times.",
            variants: ["1 kg", "2.5 kg", "5 kg"]
        ),
        Product(
            name: "Rabbit Pellets",
            species: [.smallPet], category: .food, price: 16.50, rating: 4.4, reviewCount: 587,
            summary: "Plain fibre pellets with no seeds or coloured pieces mixed in.",
            variants: ["1 kg", "3 kg"]
        ),
        Product(
            name: "Yogurt Drops",
            species: [.smallPet], category: .treats, price: 5.99, rating: 3.9, reviewCount: 412,
            summary: "Occasional treat, a few a week at most.",
            variants: []
        ),
        Product(
            name: "Chew Blocks",
            species: [.smallPet], category: .toys, price: 8.50, rating: 4.5, reviewCount: 638,
            summary: "Untreated applewood blocks that keep continuously growing teeth in check.",
            variants: []
        ),
        Product(
            name: "Exercise Wheel",
            species: [.smallPet], category: .toys, price: 29.00, rating: 4.6, reviewCount: 794,
            summary: "Solid running surface with no rungs, so feet and tails cannot catch.",
            variants: ["21 cm", "28 cm"]
        ),
        Product(
            name: "Paper Bedding",
            species: [.smallPet], category: .habitat, price: 18.99, rating: 4.7, reviewCount: 1156,
            summary: "Dust-extracted paper bedding. Absorbs well and is safe if nibbled.",
            variants: ["10 L", "20 L"]
        ),
        Product(
            name: "Grooming Brush",
            species: [.smallPet], category: .grooming, price: 9.75, rating: 4.3, reviewCount: 302,
            summary: "Soft pin brush for long-haired rabbits and guinea pigs.",
            variants: []
        ),
        Product(
            name: "Water Bottle",
            species: [.smallPet], category: .accessories, price: 12.00, rating: 4.2, reviewCount: 519,
            summary: "Glass bottle with a stainless spout, which stays cleaner than plastic.",
            variants: ["350 ml", "600 ml"]
        )
    ]
}
