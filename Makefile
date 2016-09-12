build:
	hugo
	./rewrite.sh
publish:
	git subtree push --prefix=public origin gh-pages --squash 
	ssh dstefan@login.eng.ucsd.edu 'cd public_html/cse291-fall16/ && git pull'
remove:
	git push origin :gh-pages
