# Stage1: Build the flutter web

FROM ghcr.io/cirruslabs/flutter:3.38.1 AS builder

WORKDIR /app

# Copy pubspec first to download dependencies (cache friendly)

COPY pubspec.* ./
RUN flutter pub get

# Copy rest of the app
COPY . .

# Ensure web support and build release
RUN flutter config --enable-web
RUN flutter build web --release


# Stage 2: Nginx to serve static build
FROM nginx:alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy the built web app from builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port 8000
EXPOSE 8000

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]