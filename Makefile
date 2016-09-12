build:
	hugo
	./rewrite.sh
publish:
	git subtree push --prefix=public origin gh-pages --squash 
remove:
	git push origin :gh-pages
