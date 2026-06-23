PKGNAME := postfix-ses
TAG     := main

.PHONY: build test show-version

build:
	docker build --pull -t $(PKGNAME):$(TAG) .

test: build
	docker run --rm \
		-e POSTFIX_CHECK=1 \
		-e RELAYHOST=127.0.0.1 \
		-e RELAY_NETWORKS=127.0.0.1/8 \
		-e MY_DOMAIN=test.local \
		-e SMTP_USER=test \
		-e SMTP_PASSWD=test \
		-e ROOT_MAIL=test@local \
		$(PKGNAME):$(TAG)

show-version: build
	@docker run --rm --entrypoint sh $(PKGNAME):$(TAG) -c \
		'apk info postfix 2>/dev/null | grep "^postfix-" | head -1 | cut -d- -f2 | cut -dr -f1'
