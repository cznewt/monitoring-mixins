CWD=$(shell pwd)

help:
	@echo "Available actions:"
	@echo "  generate_grafana        Generate all Grafana dashboards"
	@echo "  generate_prometheus     Generate all Prometheus alarm rules"
	@echo "  format                  Format all JSONNET files"

format:
	find ./monitor -name "*.jsonnet" | while read file; do \
		echo "Formating $$(basename $$file) ..."; \
		jsonnet fmt -i $$file; done

generate_all: generate_grafana generate_prometheus

generate_grafana:
	find ./monitor -name "*_dashboard.jsonnet" | while read file; do \
		echo "Rendering $$(basename $$file) Grafana dashboard ..."; \
		mkdir -p './build/grafana-dashboards'; \
		jsonnet -J ./vendor $$file > ./build/grafana-dashboards/$$(basename $$file | cut -d '.' -f 1).json; done

generate_prometheus:
	find ./monitor -name "*_rules.jsonnet" | while read file; do \
		echo "Rendering $$(basename $$file) Prometheus rule ..."; \
		mkdir -p './build/prometheus-rules'; \
		jsonnet -J ./vendor $$file > ./build/prometheus-rules/$$(basename $$file | cut -d '.' -f 1).json; done
