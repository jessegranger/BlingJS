
(function indexJS($) {
	$(document).ready(function () {
		$.get("js/package.json", function(text) {
			var pkg = JSON.parse(text);
			$("a[name=Top]").after("<sub>v"+pkg.version+"</sub>");
		});
	})
})(Bling)
