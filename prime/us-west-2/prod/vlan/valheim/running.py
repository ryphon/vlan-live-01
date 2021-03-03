import sys
import os
import argparse
import json
import boto3
import firebase_admin
from firebase_admin import credentials, firestore
import valve.source.a2s
from valve.source import NoResponseError


def main():
    region = os.environ.get('AWS_REGION', 'us-west-2')

    parser = argparse.ArgumentParser(description='arguments')
    parser.add_argument('--serverAddress', type=str)
    parser.add_argument('--serverPort', type=int)
    parser.add_argument('--game', type=str)
    parser.add_argument('--gameType', type=str)
    args = parser.parse_args()

    SERVER_ADDRESS = (args.serverAddress, args.serverPort)
    # server.info().values = {'response_type': 73, 'protocol': 17, 'server_name': "Garry's Mod", 'map': 'ttt_dolls', 'folder': 'garrysmod', 'game': 'TTT2 (Advanced Update)', 'app_id': 4000, 'player_count': 0, 'max_players': 16, 'bot_count': 0, 'server_type': <ServerType 100 'Dedicated'>, 'platform': <Platform 108 'Linux'>, 'password_protected': 0, 'vac_enabled': 1, 'version': '2020.03.17'}
    ssm = boto3.client('ssm', region_name=region)
    cert = json.loads(ssm.get_parameter(Name='firebase_secrets', WithDecryption=True)['Parameter']['Value'])

    firebase_creds = credentials.Certificate(cert)
    if not firebase_admin._apps:
        firebase_app = firebase_admin.initialize_app(firebase_creds)
    else:
        firebase_app = firebase_admin.get_app()
    store = firestore.client(firebase_app)

    while True:
        try:
            with valve.source.a2s.ServerQuerier(SERVER_ADDRESS) as server:
                server.info()
                # need to genericize this
                store.document(f'games/{args.game}').set({
                    f'{args.gameType}': {
                        'started': True,
                        'ready': True
                    }
                }, merge=True)
                break
        except NoResponseError:
            print('No response yet!')


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
