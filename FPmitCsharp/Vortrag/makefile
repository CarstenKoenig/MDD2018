output/slides.html: talk.md
	mkdir -p output
	pandoc -t revealjs -s -o output/slides.html talk.md -V revealjs-url=../../../reveal -V theme=sky

clean:
	rm -rf output