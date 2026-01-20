FROM julia:1.12.4

WORKDIR /app

COPY src/ ./src
RUN mkdir -p figures

RUN julia -e 'using Pkg; Pkg.add(["Images","ColorTypes","ImageIO"])'
CMD ["julia", "src/mandelbrot.jl"]
