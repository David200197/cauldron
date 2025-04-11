README: a fork of the [Cauldron VTT](https://gitlab.com/hsleisink/cauldron) project with the goal of making it easier to install the project with Docker

Cauldron VTT
============

Cauldron is a free and open source web based virtual tabletop (VTT). With its
generic dice system, you can use it for any rule and combat system you want,
but it has some extra support for systems that use the d20 dice and armor class
for combat, like Dungeons & Dragons and Pathfinder.

You can create a free account at https://www.cauldron-vtt.net/ or host it on
your own server. It's written in Javascript and PHP and uses a MySQL database
to store game information and a websocket for client-to-client communication.

![Cauldron VTT screenshot](https://gitlab.com/hsleisink/cauldron/-/raw/master/public/images/screenshot.png)

Docker
======
You can use Docker to run Cauldron. It's a simple way to get started with the
project and it will also make it easier for you to update Cauldron in the future.
To start, clone this repository:    

```bash
git clone https://gitlab.com/hsleisink/cauldron.git
```
and then build a Docker image:

```bash
cd cauldron
docker-compose up -d
```

You can access Cauldron at http://localhost:8090. You will need to create an account


# Manual
You can access to the manual game by clicking on the link below:
[Manual](./manual/README.md)






