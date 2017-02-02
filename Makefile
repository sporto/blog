serve:
	hugo server

server-draft:
	hugo server --buildDrafts

deploy:
	hugo && rsync -avz --delete public/ ${SSH_USER}@sebastianporto.com:~/public_html/blog/

ssh:
	ssh ${SSH_USER}@sebastianporto.com
