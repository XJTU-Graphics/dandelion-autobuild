import sys
from pathlib import Path
from subprocess import run
import argparse
import logging

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] [%(levelname)s] %(message)s'
)
dockerfiles = Path('./dockerfiles')

def update_archlinux():
    update_cmd = ['docker', 'pull', 'archlinux:latest']
    result = run(update_cmd)
    if result.returncode == 0:
        logging.info('archlinux image is up to date now')
    else:
        logging.warn('cannot update archlinux image, build may fail for such a rolling distribution')

def build_images():
    logging.info('build all docker images...')
    for dockerfile in dockerfiles.iterdir():
        os_name = dockerfile.stem
        image_name = f'dandelion_builder:{os_name}'
        logging.info(f'build builder image {image_name}')
        build_cmd = [
            'docker', 'buildx', 'build',
            '-t', image_name,
            '-f', dockerfile.as_posix(),
            '--network=host',
            '.'
        ]
        logging.info('run command: {}'.format(' '.join(build_cmd)))
        result = run(build_cmd, cwd='.')
        if result.returncode == 0:
            logging.info('done')
        else:
            logging.warning('failed')
    logging.info('done')

def build_dandelion():
    logging.info('run auto-build with all builder images...')
    os_names = [dockerfile.stem for dockerfile in dockerfiles.iterdir()]
    all_passed = True
    for os_name in os_names:
        container_name = f'dandelion_builder_{os_name}'
        logging.info(f'build dandelion on {os_name}')
        build_cmd = [
            'docker', 'run',
            '--name', container_name,
            '-v', './dandelion-dev:/root/dandelion-dev:ro',
            '-v', './logs:/root/build_output',
            '--net', 'host',
            f'dandelion_builder:{os_name}'
        ]
        result = run(build_cmd, cwd='.')
        if result.returncode == 0:
            logging.info('done')
        else:
            logging.error(f'compilation failed, see logs/{os_name}-[debug|release].log')
            all_passed = False
        logging.info(f'remove container {container_name}')
        clear_cmd = ['docker', 'container', 'rm', container_name]
        run(clear_cmd)
    logging.info('done')
    return all_passed

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--update', help='update the rolling distribution images', action='store_true')
    parser.add_argument('-im', '--build_images', help='build all builder images', action='store_true')
    parser.add_argument('-b', '--build', help='build dandelion with each builder image', action='store_true')
    args = parser.parse_args()
    if args.update:
        update_archlinux()
    if args.build_images:
        build_images()
    if args.build:
        all_passed = build_dandelion()
        sys.exit(not all_passed)
    if not any([args.update, args.build_images, args.build]):
        update_archlinux()
        build_images()
        all_passed = build_dandelion()
        sys.exit(not all_passed)
