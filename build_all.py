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
        logging.warning('cannot update archlinux image, build may fail for such a rolling distribution')

def build_images(image_list, use_mirror):
    if image_list is None:
        image_files = list(dockerfiles.iterdir())
    else:
        image_files = (Path(x) for x in image_list)
    logging.info('build docker images: {}'.format(image_files))
    for dockerfile in image_files:
        os_name = dockerfile.stem
        image_name = f'dandelion_builder:{os_name}'
        logging.info(f'build builder image {image_name}')
        build_cmd = [
            'docker', 'buildx', 'build',
            '-t', image_name,
            '-f', dockerfile.as_posix(),
            '--network=host',
            '.',
            '--build-arg', 'use_mirror={}'.format('true' if use_mirror else 'false')
        ]
        logging.info('run command: {}'.format(' '.join(build_cmd)))
        result = run(build_cmd, cwd='.')
        if result.returncode == 0:
            logging.info(f'successfully built builder image for {os_name}')
        else:
            logging.warning(f'failed to build builder image for {os_name}')
    logging.info('finish building builder images')

def build_dandelion(image_list, build_kind):
    if image_list is None:
        image_files = list(dockerfiles.iterdir())
    else:
        image_files = (Path(x) for x in image_list)
    logging.info('run auto-build with: {}'.format(image_files))
    os_names = [dockerfile.stem for dockerfile in image_files]
    all_passed = True
    build_result = dict()
    for os_name in os_names:
        container_name = f'dandelion_builder_{os_name}'
        logging.info(f'build dandelion on {os_name}')
        build_cmd = [
            'docker', 'run',
            '--name', container_name,
            '-v', './dandelion:/root/dandelion:ro',
            '-v', './build_output:/root/build_output',
            '--net', 'host',
            f'dandelion_builder:{os_name}',
            build_kind
        ]
        clear_cmd = ['docker', 'container', 'rm', '-f', container_name]
        try:
            result = run(build_cmd, cwd='.')
        except KeyboardInterrupt:
            # Stop container when Ctrl+C is pressed
            run(clear_cmd)
            raise
        build_result[os_name] = 'success' if result.returncode == 0 else 'failed'
        if result.returncode == 0:
            logging.info('done')
        else:
            logging.error(f'compilation failed, see logs/{os_name}-[debug|release].log')
            all_passed = False
        logging.info(f'remove container {container_name}')
        run(clear_cmd)
        
    logging.info(f'finish building dandelion ({build_kind}), result:')
    logging.info('{:<15}{:<10}'.format('Distro', 'Result'))
    logging.info('=========================')
    for os_name in build_result:
        logging.info(f'{os_name:<15}{build_result[os_name]:<10}')
    return all_passed

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--update', help='update the rolling distribution images', action='store_true')
    parser.add_argument('-i', '--image', help='select which image to use', nargs='*', default=None)
    parser.add_argument('--build-images', help='build all builder images', action='store_true')
    parser.add_argument('-b', '--build', help='build dandelion with each builder image', action='store_true')
    parser.add_argument('--build-kind', help='which version and thing to build, can be one of dev/lib/release/test', default='dev')
    parser.add_argument('--use-mirror', help='use "mirrors.tuna.tsinghua.edu.cn" for updating system packages', action='store_true')
    args = parser.parse_args()
    if args.update:
        update_archlinux()
    if args.build_images:
        build_images(args.image, args.use_mirror)
    if args.build:
        all_passed = build_dandelion(args.image, args.build_kind)
        sys.exit(not all_passed)
    if not any([args.update, args.build_images, args.build]):
        update_archlinux()
        build_images(args.image, args.use_mirror)
        all_passed = build_dandelion(args.image, args.build_kind)
        sys.exit(not all_passed)
