macro "myAutoCorp [c]" {
	sizeX = 330; sizeY = 330;
	getCursorLoc(x, y, z, flags);
	makeRectangle(x-sizeX/2, y-sizeY/2, sizeX, sizeY);
	run("Crop");
	run("Save");
	run("Open Next");
}