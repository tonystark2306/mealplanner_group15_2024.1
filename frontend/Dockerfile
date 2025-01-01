FROM cirrusci/flutter:latest as build

WORKDIR /app

COPY . .
RUN flutter pub get --no-example
RUN flutter build web --web-renderer html --release


FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]