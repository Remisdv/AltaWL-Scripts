document.addEventListener('DOMContentLoaded', () => {
    const closeBtn = document.getElementById('close-btn');
    const mapContainer = document.getElementById('map-container');
    const mapImage = document.getElementById('map-image');
    const canvas = document.getElementById('zones-canvas');
    const ctx = canvas.getContext('2d');

    let zoomLevel = 1; // Niveau de zoom initial à 1
    const maxZoom = 5; // Zoom maximum (5x)
    const minZoom = 1; // Zoom minimum (1x)
    const zoomStep = 0.1;
    let isPanning = false;
    let startX, startY;

    const numHorizontalLines = 30; // 30 lignes horizontales
    const numVerticalLines = 50; // 50 lignes verticales pour faire des carrés

    const zoneColors = {}; // Dictionnaire pour stocker les couleurs des zones

    // Convert RGB color to RGBA with 80% transparency
    function toRgba(color) {
        if (color.startsWith('rgb')) {
            return color.replace('rgb', 'rgba').replace(')', ', 0.4)');
        }
        return color;
    }

    function drawGrid() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        const stepX = canvas.width / numVerticalLines; // Espacement des lignes verticales
        const stepY = canvas.height / numHorizontalLines; // Espacement des lignes horizontales pour faire des carrés

        ctx.lineWidth = 1; // Lignes plus fines
        ctx.font = "8px Arial"; // Smaller font size
        ctx.fillStyle = "rgba(0, 0, 0, 0)";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";

        for (let i = 0; i < numVerticalLines; i++) {
            for (let j = 0; j < numHorizontalLines; j++) {
                const x = i * stepX;
                const y = j * stepY;
                const cellNumber = i + j * numVerticalLines;

                // Colorier chaque case
                if (zoneColors[cellNumber]) {
                    ctx.fillStyle = toRgba(zoneColors[cellNumber]); // Convert color to RGBA with 80% transparency
                } else {
                    ctx.fillStyle = 'rgba(0, 0, 0, 0)';
                }
                ctx.fillRect(x, y, stepX, stepY);

                // Dessiner le numéro de la case
                if (zoneColors[cellNumber]) {
                    ctx.fillStyle = "black";
                    ctx.fillText(cellNumber, x + stepX / 2, y + stepY / 2);
                }

                // Dessiner les lignes verticales et horizontales
                ctx.strokeStyle = 'rgba(0, 0, 0, 0)'; // Couleur des lignes de la grille transparente
                ctx.beginPath();
                ctx.moveTo(x, 0);
                ctx.lineTo(x, canvas.height);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(canvas.width, y);
                ctx.stroke();
            }
        }
    }

    function updateCanvasSize() {
        canvas.width = mapImage.clientWidth;
        canvas.height = mapImage.clientHeight;
    }

    function updateMapTransform() {
        mapImage.style.transform = `translate(-50%, -50%) scale(${zoomLevel})`;
        canvas.style.transform = `translate(-50%, -50%) scale(${zoomLevel})`;
        updateCanvasSize();
        drawGrid();
        console.log(`Zoom Level: ${zoomLevel}`);
    }

    document.addEventListener('keydown', (event) => {
        const step = 10 / zoomLevel; // Ajuste le déplacement en fonction du niveau de zoom
        switch (event.key) {
            case 'ArrowUp':
                mapImage.style.top = `${mapImage.offsetTop - step}px`;
                canvas.style.top = `${canvas.offsetTop - step}px`;
                break;
            case 'ArrowDown':
                mapImage.style.top = `${mapImage.offsetTop + step}px`;
                canvas.style.top = `${canvas.offsetTop + step}px`;
                break;
            case 'ArrowLeft':
                mapImage.style.left = `${mapImage.offsetLeft - step}px`;
                canvas.style.left = `${canvas.offsetLeft - step}px`;
                break;
            case 'ArrowRight':
                mapImage.style.left = `${mapImage.offsetLeft + step}px`;
                canvas.style.left = `${canvas.offsetLeft + step}px`;
                break;
            case 'z':
                if (zoomLevel < maxZoom) {
                    zoomLevel += zoomStep;
                    updateMapTransform();
                }
                break;
            case 's':
                if (zoomLevel > minZoom) {
                    zoomLevel -= zoomStep;
                    updateMapTransform();
                }
                break;
            case 'Escape':
                fetch(`https://${GetParentResourceName()}/close`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({})
                }).then(resp => resp.json()).then(resp => {
                    console.log(resp);
                    document.body.style.display = 'none';
                }).catch(error => console.error('Error:', error));
                break;
        }
    });

    mapImage.addEventListener('wheel', (event) => {
        if (event.deltaY < 0 && zoomLevel < maxZoom) {
            zoomLevel += zoomStep;
        } else if (event.deltaY > 0 && zoomLevel > minZoom) {
            zoomLevel -= zoomStep;
        }
        updateMapTransform();
        event.preventDefault();
    });

    mapContainer.addEventListener('mousedown', (event) => {
        isPanning = true;
        startX = event.clientX - mapImage.offsetLeft;
        startY = event.clientY - mapImage.offsetTop;
        mapContainer.style.cursor = 'grabbing';
        event.preventDefault(); // Empêche le comportement de copie/déplacement par défaut
    });

    mapContainer.addEventListener('mouseup', () => {
        isPanning = false;
        mapContainer.style.cursor = 'grab';
    });

    mapContainer.addEventListener('mousemove', (event) => {
        if (!isPanning) return;
        const x = event.clientX - startX;
        const y = event.clientY - startY;
        mapImage.style.left = `${x}px`;
        mapImage.style.top = `${y}px`;
        canvas.style.left = `${x}px`;
        canvas.style.top = `${y}px`;
        event.preventDefault();
    });

    closeBtn.addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({})
        }).then(resp => resp.json()).then(resp => {
            console.log(resp);
            document.body.style.display = 'none';
        }).catch(error => console.error('Error:', error));
    });
    
    window.addEventListener('message', (event) => {
        if (event.data.action === 'open') {
            document.body.style.display = 'block';
            zoomLevel = 1; // Niveau de zoom initial à 1
            updateMapTransform();
            console.log("Interface ouverte");
        } else if (event.data.action === 'close') {
            document.body.style.display = 'none';
            console.log("Interface fermée");
        } else if (event.data.action === 'updateZones') {
            event.data.zones.forEach(zone => {
                zoneColors[zone.zone_number] = zone.color;
            });
            drawGrid();
        } else if (event.data.action === 'setZoneColor') {
            const { zone, color } = event.data;
            zoneColors[zone] = color;
            drawGrid();
        }
    });

    updateCanvasSize();
    drawGrid();
    updateMapTransform();
});
