from invoke import task


DOCKER_COMPOSE_FILES = ['docker-compose-deps.yaml', 'docker-compose.yaml']


def docker_compose_with_deps(command, flags=None):
    flags = flags or []
    cmd = ['docker-compose']
    for file in DOCKER_COMPOSE_FILES:
        cmd.append('-f {}'.format(file))
    cmd.append(command)
    for flag in flags:
        if len(flag) == 1:
            cmd.append('-{}'.format(flag))
        else:
            cmd.append('--{}'.format(flag))
    return cmd


@task(default=True)
def up(ctx, d=False):
    flags = ['abort-on-container-exit']
    if d:
        flags.append('d')
    ctx.run(
        docker_compose_with_deps('up', flags=flags)
    )


@task(default=True)
def down(ctx):
    ctx.run(
        docker_compose_with_deps('down', flags=['volumes'])
    )


@task(default=True)
def rm(ctx):
    ctx.run(
        docker_compose_with_deps('rm', flags=['volumes'])
    )
