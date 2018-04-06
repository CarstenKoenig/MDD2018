dist/bundle.js: src/Main.purs src/Notify.purs src/Notify.js
	bower install
	pulp build --to dist/bundle.js

clean:
	rm dist/Main.purs
	rm -rf bower_components
	rm -rf output