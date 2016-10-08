# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

stations = WeatherStation.create([
    {
        latitude: 24.860971,
        longitude: -100.413901,
        name: "Catarino Rodríguez",
    },
    {
        latitude: 45.563092,
        longitude: -116.971135,
        name: "Zumwalt Prarie Preserve",
    }
])
