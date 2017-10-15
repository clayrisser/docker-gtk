all: build

src/main:
	gcc `pkg-config --cflags gtk+-3.0` -o main main.c `pkg-config --libs gtk+-3.0`

.PHONY: build
build:
	docker build -t jamrizzi/docker-gtk:latest -f deployment/Dockerfile .
	@echo ::: built :::

.PHONY: run
run:
	docker run -ti --rm -e DISPLAY=$(DISPLAY) -v /tmp/.X11-unix:/tmp/.X11-unix jamrizzi/docker-gtk:latest

.PHONY: push
push:
	docker push jamrizzi/docker-gtk:latest

.PHONY: clean
clean:
	@rm -f ./main
	@echo ::: cleaned :::
