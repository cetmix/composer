
help:
	@echo 'Available targets:'
	@echo '  make deploy'

deploy:
	./scripts/deploy.sh
	
terminate:
	./scripts/deploy.sh down
