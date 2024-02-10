# Debian 12 image
FROM amd64/julia:1.10.0-bookworm

WORKDIR /app
COPY . .

CMD ["bash"]
USER root

# Needed to build Blink.jl (dep for PlotlyJS.jl)
RUN apt-get update
RUN apt-get install --no-install-recommends unzip

# Set API environment variables
ARG key_av
ARG key_cg
ENV KEY_AV $key_av
ENV KEY_CG $key_cg

# Install dependencies
RUN julia -e 'using Pkg; Pkg.activate(pwd()); Pkg.instantiate()'

# Run the app
CMD ["julia", "src/docker_app.jl"]

# Expose port to access the web page
EXPOSE 8010