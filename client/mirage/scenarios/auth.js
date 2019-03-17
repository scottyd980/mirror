import { Response } from 'ember-cli-mirage';
import { current_user, access_token, registration_errors } from '../data/auth/user';

export function login_success(server) {
  server.post("/token", () => {
    return new Response(201, {}, access_token());
  });

  server.get("/user/current", () => {
    return new Response(200, {}, current_user());
  });
}

export function login_failure(server) {
  server.post("/token", () => {
    return new Response(401, {}, {});
  })
}

export function register_success(server) {
  server.post("/register", () => {
    return new Response(201, {}, current_user() )
  });

  server.post("/token", () => {
    return new Response(201, {}, access_token());
  });

  server.get("/user/current", () => {
    return new Response(200, {}, current_user());
  });
}

export function register_failure(server) {
  server.post("/register", () => {
    return new Response(422, {}, registration_errors() )
  });
}