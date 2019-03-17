export function current_user() {
  return { 
    "data": { 
      "attributes": { 
        "email": "test@test.com", 
        "username": "test" }, 
        "id": "1", 
        "relationships": { 
          "organizations": { 
            "data": [], 
            "links": { "self": "/api/organizations/" } 
          }, 
          "teams": { 
            "data": [], 
            "links": { "self": "/api/teams/" } 
          } 
        }, 
        "type": "user" 
      }, 
      "jsonapi": { "version": "1.0" } 
    };
}

export function access_token() {
  return { 
    "access_token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJNaXJyb3IiLCJleHAiOjE1NTUyOTA4OTgsImlhdCI6MTU1MjY5ODg5OCwiaXNzIjoiTWlycm9yIiwianRpIjoiNTRkYmE4ZmUtMjJiOC00OTcyLTk5MTItYTc2N2U0YTkyZDMwIiwibmJmIjoxNTUyNjk4ODk3LCJzdWIiOiJVc2VyOjEiLCJ0eXAiOiJhY2Nlc3MifQ.4sxR2h1CWwvM-O-3OmZMmRrBmukS5gqMEX51kIO9rBD-E6RfEAdqlYLiJGSuoLwBo4nt3QoNVIqiDoAUCnsVEQ" 
  }
}

export function registration_errors() {
  return {
    "errors": [
      {
        "detail": "Username can't be blank",
        "source": {
          "pointer": "/data/attributes/username"
        },
        "title": "can't be blank"
      },
      {
        "detail": "Email can't be blank",
        "source": {
          "pointer": "/data/attributes/email"
        },
        "title": "can't be blank"
      },
      {
        "detail": "Password can't be blank",
        "source": {
          "pointer": "/data/attributes/password"
        },
        "title": "can't be blank"
      },
      {
        "detail": "Password confirmation can't be blank",
        "source": {
          "pointer": "/data/attributes/password-confirmation"
        },
        "title": "can't be blank"
      }
    ],
    "jsonapi": {
      "version": "1.0"
    }
  };
}