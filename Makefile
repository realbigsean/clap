FEATURES = "wrap_help yaml regex unstable-replace unstable-multicall"

.PHONY: lint-minimal lint-full fmt-check lint bench tests test debug clean count-errors find-errors count-warnings find-warnings

lint-minimal:
	cargo clippy --no-default-features --features "std cargo" -p clap:3.0.0-beta.4 -- -D warnings

lint-full:
	cargo clippy --features $(FEATURES) -- -D warnings

fmt-check:
	cargo fmt -- --check

lint: lint-minimal lint-full fmt-check

bench:
	cargo bench -- --output-format bencher

tests:
	cargo test --features $(FEATURES)

test:
ifeq (3, $(words $(MAKECMDGOALS)))
	cargo test --features $(FEATURES) --test $(word 2,$(MAKECMDGOALS)) -- $(word 3,$(MAKECMDGOALS))
else
	cargo test --features $(FEATURES) --test $(word 2,$(MAKECMDGOALS))
endif

debug:
ifeq (3, $(words $(MAKECMDGOALS)))
	cargo test --features $(FEATURES) --features debug --test $(word 2,$(MAKECMDGOALS)) -- $(word 3,$(MAKECMDGOALS)) --nocapture
else
	cargo test --features $(FEATURES) --features debug --test $(word 2,$(MAKECMDGOALS)) -- --nocapture
endif

clean:
	cargo clean
	find . -type f -name "*.orig" -exec rm {} \;
	find . -type f -name "*.bk" -exec rm {} \;
	find . -type f -name ".*~" -exec rm {} \;

count-errors:
	@cargo check 2>&1 | grep -e '^error' | wc -l

find-errors:
	@cargo check 2>&1 | grep --only-matching -e '-->[^:]*' | sort | uniq -c | sort -nr

count-warnings:
	@cargo check 2>&1 | grep -e '^warning' | wc -l

find-warnings:
	@cargo check 2>&1 | grep -A1 -e 'warning' | grep --only-matching -e '-->[^:]*' | sort | uniq -c | sort -nr
