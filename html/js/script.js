let currentPlant = null;

window.addEventListener('message', function(event) {
    if (event.data.action === "openPlantMenu") {
        const d = event.data.data;
        currentPlant = d;

        // Prikazi meni
        document.body.style.display = "block";

        // Popuni podatke
        $("#growth-val").text(d.growth + "%");
        $("#growth").css("width", d.growth + "%").css("background", getColor(d.growth));

        $("#health-val").text(d.quality + "%");
        $("#health").css("width", d.quality + "%").css("background", getColorByScheme(d.qualityColor));

        $("#water-val").text(d.thirst + "%");
        $("#water").css("width", d.thirst + "%").css("background", getColorByScheme(d.thirstColor));

        $("#fertilizer-val").text(d.hunger + "%");
        $("#fertilizer").css("width", d.hunger + "%").css("background", getColorByScheme(d.hungerColor));
    }
});

function getColor(percent) {
    if (percent > 50) return "#27ae60";
    if (percent > 10) return "#f1c40f";
    return "#e74c3c";
}
function getColorByScheme(scheme) {
    if (scheme === "green") return "#27ae60";
    if (scheme === "yellow") return "#f1c40f";
    return "#e74c3c";
}

// Dugmad
function Give(type) {
    if (!currentPlant) return;
    if (type === "Water") {
        $.post("https://qc-farming/waterPlant", JSON.stringify({ plantid: currentPlant.id }));
    } else if (type === "Fertilizer") {
        $.post("https://qc-farming/feedPlant", JSON.stringify({ plantid: currentPlant.id }));
    } else if (type === "Harvest") {
        $.post("https://qc-farming/harvestPlant", JSON.stringify({ plantid: currentPlant.id, growth: currentPlant.growth }));
    }
    closex();
}

function closex() {
    document.body.style.display = "none";
    $.post("https://qc-farming/closePlantMenu", JSON.stringify({}));
}

// ESC za zatvaranje
document.addEventListener('keydown', function(e) {
    if (e.key === "Escape") closex();
});