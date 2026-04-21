# --- Project Configuration ---
SHELL := /bin/bash
.PHONY: all help docker sim wave clean delete

# Isolated Naming to prevent leakage
PROJ_NAME   := mac_q17
DOCKER_NAME := $(PROJ_NAME)_env
IMAGE_NAME  := $(PROJ_NAME)_image:latest

# Directory Structure
RTL_DIR     := rtl
TB_DIR      := tb
BUILD_DIR   := work

# Simulation Artifacts
SIM_OUT     := $(BUILD_DIR)/mac_sim.out
VCD_FILE    := $(BUILD_DIR)/dump.vcd

# --- Help Target ---
help: ## Show this help message
	@echo "Available Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

# --- Docker Management ---
docker: ## Build/Start the Docker container and mount the current workspace
	@if [ $$(docker ps -a -q -f name=$(DOCKER_NAME)) ]; then \
		echo "Starting existing container: $(DOCKER_NAME)..."; \
		docker start -ai $(DOCKER_NAME); \
	else \
		echo "Building new image and launching container..."; \
		docker build -t $(IMAGE_NAME) .; \
		docker run --name $(DOCKER_NAME) -it \
			-v $$(pwd):/workspace \
			-w /workspace \
			$(IMAGE_NAME) /bin/bash; \
	fi

# --- RTL Build & Simulation ---
sim: $(SIM_OUT) ## Compile RTL and run the simulation using Icarus Verilog
	vvp $(SIM_OUT)

$(SIM_OUT):
	@mkdir -p $(BUILD_DIR)
	iverilog -g2012 \
		-I $(RTL_DIR) \
		$(RTL_DIR)/*.v \
		$(TB_DIR)/testbench.v \
		-o $(SIM_OUT)

# --- Waveform Visualization ---
wave: ## Open GTKWave to view the simulation waveforms (VCD)
	@if [ -f $(VCD_FILE) ]; then \
		gtkwave $(VCD_FILE) & \
	else \
		echo "Error: VCD file not found. Run 'make build' first."; \
	fi

# --- Cleanup ---
clean: ## Remove build artifacts and temporary simulation files
	rm -rf $(BUILD_DIR)

delete: ## Stop and remove the Docker container and associated image
	docker rm -f $(DOCKER_NAME) || true
	docker rmi -f $(IMAGE_NAME) || true
