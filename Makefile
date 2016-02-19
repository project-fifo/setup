.PHONY: doc compile test compile_test clean_test run_test escriptize deps eunit

REBAR ?= $(shell test -e `which rebar3` 2>/dev/null && which rebar3 || echo "./rebar3")

TESTDIRS= xtest/testapp-1 xtest/testapp-2

SETUP_GET = ./_build/default/bin/setup_gen
SETUP_PLT = setup.plt
DIALYZER_OPTS = # -Wunderspecs
DIALYZER_APPS = erts kernel stdlib sasl

all: compile

compile:
	${REBAR} compile

doc:
	${REBAR} doc

compile_test:
	for D in $(TESTDIRS) ; do \
	(cd $$D; ${REBAR} compile) ; \
	done

clean_test:
	for D in $(TESTDIRS) ; do \
	(cd $$D; ${REBAR} clean) ; \
	done
	rm -r xtest/releases

eunit:
	${REBAR} eunit

test: escriptize eunit compile_test
	cp ${SETUP_GET} setup_gen
	./setup_gen test xtest/test.conf xtest/releases/1 -pa ${PWD}/_build/default/lib/setup/ebin

run_test:
	erl -boot xtest/releases/1/start -config xtest/releases/1/sys

escriptize:
	${REBAR} escriptize

dialyzer:
	${REBAR} dialyzer

ci: eunit test dialyzer
	erl -boot xtest/releases/1/start -config xtest/releases/1/sys -s init stop
