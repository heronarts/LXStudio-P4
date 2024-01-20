document.addEventListener("DOMContentLoaded", function () {
  const canvas = document.getElementById("spiralCanvas");
  const ctx = canvas.getContext("2d");

  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  let angle = 0;
  let paused = false;
  let step = 0.03; // The increment of the angle per frame
  let centerX = canvas.width / 2;
  let centerY = canvas.height / 2;

  function drawSpiral() {
    ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear the canvas

    for (let j = 0; j < 3; j++) {
      // Draw 3 lines
      ctx.beginPath();
      ctx.moveTo(centerX, centerY);
      let localAngle = angle + (j * Math.PI * 2) / 3; // Offset each line by 120 degrees

      for (let i = 0; i < 360 * 5; i++) {
        localAngle += 0.01; // Smaller increments for smoother spiral
        let x = centerX + 5.5 * i * Math.cos(localAngle + 0.1 * i);
        let y = centerY + 5.5 * i * Math.sin(localAngle + 0.1 * i);
        ctx.lineTo(x, y);
      }

      ctx.strokeStyle = `hsl(${(360 * j) / 3}, 100%, 50%)`; // Different color for each line
      ctx.stroke();
    }
  }

  function update() {
    if (!paused) {
      angle += step;
    }
    drawSpiral();
    requestAnimationFrame(update);
  }

  function togglePause() {
    paused = !paused;
  }

  function stepAnimation(direction) {
    if (paused) {
      angle += step * direction;
      drawSpiral();
    }
  }

  document.addEventListener("keydown", function (event) {
    if (event.code === "Space") {
      togglePause();
    } else if (event.code === "ArrowRight") {
      stepAnimation(1);
    } else if (event.code === "ArrowLeft") {
      stepAnimation(-1);
    }
  });

  update();
});
