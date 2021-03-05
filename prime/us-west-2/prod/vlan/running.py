import sys
import os
import argparse
import json
import boto3
import requests
import firebase_admin
from firebase_admin import credentials, firestore


def documentStore(game, gameType, name, ip):
    region = os.environ.get('AWS_REGION', 'us-west-2')
    ssm = boto3.client('ssm', region_name=region)
    cert = json.loads(ssm.get_parameter(Name='firebase_secrets', WithDecryption=True)['Parameter']['Value'])

    firebase_creds = credentials.Certificate(cert)
    if not firebase_admin._apps:
        firebase_app = firebase_admin.initialize_app(firebase_creds)
    else:
        firebase_app = firebase_admin.get_app()
    store = firestore.client(firebase_app)

    store.document(f'games/{game}').set({
        f'{gameType}': {
            'name': name,
            'started': True,
            'ready': True,
            'ipAddress': ip
        }
    }, merge=True)


def main():

    parser = argparse.ArgumentParser(description='arguments')
    parser.add_argument('--serverAddress', type=str)
    parser.add_argument('--serverPort', type=int)
    parser.add_argument('--game', type=str)
    parser.add_argument('--gameType', type=str)
    parser.add_argument('--name', type=str)
    args = parser.parse_args()

    ip = requests.get('http://169.254.169.254/latest/meta-data/public-ipv4').text

    while True:
        if args.game in ('soldat', 'gmod', 'valheim'):
            import valve.source.a2s
            from valve.source import NoResponseError
            try:
                SERVER_ADDRESS = (args.serverAddress, args.serverPort)
                with valve.source.a2s.ServerQuerier(SERVER_ADDRESS) as server:
                    server.info()
                    # need to genericize this
                    documentStore(args.game, args.gameType, args.name, ip)
                    break
            except NoResponseError:
                print('No response yet!')
        elif args.game == 'minecraft':
            from mcstatus import MinecraftServer
            try:
                SERVER_ADDRESS = [args.serverAddress, args.serverPort]
                server = MinecraftServer(SERVER_ADDRESS[0], SERVER_ADDRESS[1])
                server.ping()
                documentStore(args.game, args.gameType, args.name, ip)
                break
            except Exception as e:
                print('No response yet! However, {}'.format(e))


if __name__ == '__main__':
    try:
        main()
    except SystemExit:
        raise
    except KeyboardInterrupt:
        sys.exit(2)
    except Exception:
        import traceback
        print(*traceback.format_exception_only(*sys.exc_info()[:2]), end='')
        traceback.print_exc()
