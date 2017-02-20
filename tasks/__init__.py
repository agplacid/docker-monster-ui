import os

from invoke import task, Collection

from . import test, dc, kube, sup


COLLECTIONS = [test, dc, kube, sup]

ns = Collection()
for c in COLLECTIONS:
    ns.add_collection(c)

ns.configure(dict(
    project='monsterui',
    repo='docker-monsterui',
    pwd=os.getcwd(),
    docker=dict(
        user=os.getenv('DOCKER_USER'),
        tag='%s/%s:latest' % (os.getenv('DOCKER_USER'), 'monsterui')
    ),
    kube=dict(
        environment='testing'
    )
))
