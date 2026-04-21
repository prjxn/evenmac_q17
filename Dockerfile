FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential make cmake git \
	dos2unix wget curl ca-certificates \
	python3 python3-pip python3-venv \
	clang clang-format \
	iverilog verilator yosys zlib1g-dev gtkwave \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH="/usr/lib/llvm-18/lib:/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}"
RUN ln -s /usr/lib/llvm-18/lib/libLLVM-18.so /usr/lib/x86_64-linux-gnu/libLLVM-18.so.18.1 || true

WORKDIR /workspace
ENV PATH="/workspace/.local/bin:${PATH}"

CMD ["/bin/bash"]
