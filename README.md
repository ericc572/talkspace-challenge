# Talkspace SRE Take Home Interview Submission - Eric Chen 

## Introduction
This is my implementation of a web service, using Sinatra (A simple DSL for Ruby API's) and uses Thin as the underlying web server. Thanks for this opportunity! It was a challenging, but fun exercise.


## Design
I used *sinatra* because it's the most barebone Ruby web framework, and is quick and easy to set up. 

I used *THIN* for the web server because it supports ssl in development, is light and fast, and can scale to production.

## Endpoints
It supports the following three endpoints: 
* GET /messages OR GET /all-messages
* POST /messages
* GET /message/:message_sha 

This code is structured as follows:
* ssl/ 
    - contains the certificate and key used to sign/validate the certificate.
* routes/
    - similar to controllers in Rails, routes have a more explicit DSL and handle all incoming requests and responses.
* models/
    - I like service objects, and simple design patterns. For this reason, I used a PORO (Plain Old Ruby Object) to model a MessageList.

## Running locally
First install all gems
```sh
$ bundle install
```

To start the thin server with SSL and the self signed certificate (Also specified in CMD in Dockerfile), do:

```sh
$ thin start -p 5000 --ssl --ssl-key-file ./ssl/server.key --ssl-cert-file ./ssl/server.crt
```

This tells thin to bind to port 5000, and finds the relevant ssl-key and ssl-cert files.

## Running via Docker 
First build the container sinatra-app, then we can use docker-compose.
Do this via:
``` 
    $ docker build . -t sinatra-app
```

```
    $ docker-compose up
```


## Q&A 
1. How would your implementation scale if this were a high throughput service, and how could you improve that?

> I would use a load balancer to sit in front of the Ruby server (Nginx), and distribute load accordingly. We'd probably introduce horizontal scaling and add multiple processes running the thin server. In addition, we probably need persistent storage and a database layer. With a high volume of requests, we might want to introduce some caching and read-only followers.

2. How would you deploy this to the cloud, using the provider of your choosing? What cloud
services/tools would you use?

> I'd use AWS, or Heroku just because I'm most familiar with it :D 

> Just kidding. Heroku is painless and easy, and they have an out-of-the-box ACM (Automated Certificate Management) which uses Let's Encrypt under the hood. We'd then leverage features like autoscaling, and use multiple dynos for our web process. 

> AWS is another great option for more granular control and better cost. I'd imagine at a high level, we'd need to deploy our Docker container to ECS/Fargate, and have a running service + task definition(s) behind an ELB.

3. How would you monitor this service? What metrics would you collect? How would you
act on these metrics?

> Great question. I love actionable metrics, and absolutely despise non-actionable ones. I love a good, reliable log drain (Splunk or Coralogix are my favorite) and high level dashboards.

 In an ideal world, we obviously want to measure, and possibly chart even:
- health checks to ensure uptime /health 
- Count of 4XX or 5XX requests (can use AWS monitoring tools out of the box)
- CPU/Memory Usage + load, capacity percentage.
- Overall # of requests /min
- Overall # of errors, what are the most frequent ones?
- Avg/Max Latency of each/all requests
- Top Users/other key business insights


4. What are some security concerns/improvements you could make to this system if we
were to assume the message text was sensitive

> You already made me enforce HTTPS/TLS encryption using a self signed certificate , so that's a good start :D

I'd also add: 
- **Authentication** using a Bearer Token. Some implementation of OAuth + OpenID works great because we can do both resource authorization + authentication. We'd be able to control access to given resources too as we scale and grow. My favorite gem is omniauth to do this :) 
- As a service grows, the number of external libraries or gems might grow as well. Ensure that **vulnerabilities** are taken care of, and the most up to date versions are installed so there isn't any XSS or SQL injection attacks or exploits.
- Place **rate limits** and throttling on how many times a client can make a request. This would protect a bug from being in an endless for loop, or prevent a DOS.


## Notes + Learnings
- Ran into issues while validating the certificate because I didn't specify a common name while generating the certificate with `openssl`. Turns out the -v flag in curl is a really good friend :) 

- I also thought about using Nginx as a reverse proxy to sit in front of all requests, and do the certificate validation. It'd be simulateously started in the docker compose file, and would be a 1:1 mapping with the Thin Server. This is probably a better practice in production, as it could also help with load balancing.
