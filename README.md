Servers
=======
A collection of common server setups as described by [this article](https://www.digitalocean.com/community/tutorials/5-common-server-setups-for-your-web-application). All of them use vagrant to setup all of them VMs and their respective connections. Nothing fancy is done to setup each individual VM (no use of Chef, Ansible, Puppet, and etc.). Instead, each one is setup using different shell scripts (for better or worse).


Usage
=====

Each folder is a separate server setup (except base_project which is a basic django application). To run any of them you just need vagrant and virtualbox installed. The specific usage for each one is listed below. To remove the VMs, just replace `up` in each command with `destroy -f`. After the servers are up you can access them by going to `http://localhost:4567/` with your browser.


one_server
----------
This is the most basic form of setup. It is nginx + postgres + django all on one server.

    $ vagrant up


database_server
---------------
This is a two server setup. The first server has nginx + django on it, and the second server is a dedicated database server with postgres.

    $ vagrant up


load_balancer
-------------
This is a 1 + N + 1 server setup with one nginx server for a load balancer, N servers that have nginx + django, and a final dedicated postgres database server that is shared between the django apps.

    $ NODES=4 vagrant up


cache_server
------------
This is a 3 server setup. The first is a varnish server, the second is nginx + django, and the last is a postgres database.

    $ vagrant up


master_slave
-------------
This is a 1 + N + (1 + M) server setup. The first server is an nginx server for load balancing, the second layer is N nginx + django servers and the final layer is 1 + M postgres databases. The first of these databases is the master server and the remaining are all slaves that replicate from that server. On the django side of things, all the django apps write only to the master, and they read from any of the database servers.

    $ APPS=3 SLAVES=2 vagrant up



Results
=======

The raw data (along with the setup used) is located in each folder in `results.txt`.
All of these tests were done using `ab` for 1000 requests (20 concurrent). Specifically the following:

    $ ab -n 1000 -c 20 http://127.0.0.1:4567$URL
    # Where $URL is one of /, /info/, or /lorem/

NOTE: These were all VMs running on the same machine so take this all with a grain of salt.


one_server
----------

    Path        Requests per second (mean)
    /           14.62
    /info/      227.18
    /lorem/     230.98



database_server
---------------

    Path        Requests per second (mean)
    /           13.63
    /info/      206.45
    /lorem/     218.58



load_balancer (NODES=2)
-----------------------

    Path        Requests per second (mean)
    /           16.54
    /info/      307.38
    /lorem/     326.13


load_balancer (NODES=4)
-----------------------

    Path        Requests per second (mean)
    /           16.97
    /info/      391.65
    /lorem/     393.84



cache_server
------------

    Path        Requests per second (mean)
    /           13.61
    /info/      1455.44
    /lorem/     1065.72



master_slave (SLAVES=1 APPS=2)
------------------------------

    Path        Requests per second (mean)
    /           20.09
    /info/      304.51
    /lorem/     296.77


master_slave (SLAVES=3 APPS=4)
------------------------------

    Path        Requests per second (mean)
    /           22.36
    /info/      396.68
    /lorem/     384.37