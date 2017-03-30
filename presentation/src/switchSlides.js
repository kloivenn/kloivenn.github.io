var slideList = ["", "index.html", "CombinAssay.html", "slide03.html", "slide04.html", "slide05.html",
	"slide06.html", "slide07.html", "layers.html",  "slide08.html", "linesAndColour.html", "colourSlider.html",
	"twoChanel.html", "ASC_AC_withHeatmap.html", "recalculate.html"]

document.onkeydown = function(evt){
	
	var n = slideList.indexOf(document.location.href.replace(/^.*[\\\/]/, '')),
		path = document.location.href.match(/^.*[\\\/]/, '');
	
	if(n == -1)
		throw "Error: something is wrong! :)";

	if(evt.keyCode == 37){
		//go to the previous slide
		if(n > 0)
			window.open(path + slideList[n - 1],"_self");
	}

	if(evt.keyCode == 39 || evt.keyCode == 32){
		//go to the next slide
		if(n < slideList.length - 1)
			window.open(path + slideList[n + 1], "_self");
	}
}