return {
    {
        key = "mix_stroke_color",
        type = "select",
        default = "none",
        values = { "none", "white", "black", "remove" },
        label = "Mix Stroke Override",
        description = "Override the color of the stroke around wheel/boxes when mixing, or force remove the stroke with `remove`",
    },
    {
        key = "scraper_screenscraper_gameid",
        type = "numpad",
        default = nil,
        options = {
            maxLength = 7,
        },
        label = "Screenscraper Game ID",
        description = "Supply a specific game ID when scraping from screenscraper.fr. Allows matching of otherwise missing images",
    },
}
