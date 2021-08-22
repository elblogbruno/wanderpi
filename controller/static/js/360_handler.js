function load_360_image(path){
	console.log(path);
	var viewer = new Marzipano.Viewer(document.getElementById('pano'));

	// Create source.
	var source = Marzipano.ImageUrlSource.fromString(
	  path
	);

	// Create geometry.
	var geometry = new Marzipano.EquirectGeometry([{ width: 4000}]);

	// Create view.
	//var limiter = Marzipano.RectilinearView.limit.traditional(1024, 100*Math.PI/180);
	var limiter = Marzipano.RectilinearView.limit.traditional(1024, 100*Math.PI/180);
	
	var view = new Marzipano.RectilinearView({ yaw: Math.PI }, limiter);

	// Create scene.
	var scene = viewer.createScene({
	  source: source,
	  geometry: geometry,
	  view: view,
	  pinFirstLevel: true
	});

	// Display scene.
	scene.switchTo();
}