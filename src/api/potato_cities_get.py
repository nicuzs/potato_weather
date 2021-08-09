import json
import os
from urllib import request
from typing import Optional


def lambda_handler(event, context):
    city_name = (event.get('queryStringParameters') or {}).get('city_name')
    headers = {
        'Content-Type': 'application/json',
    }

    if not city_name:
        return {
            'headers': headers,
            'statusCode': 400,
            'body': 'Expected to receive city_name=? as query string param!'
        }

    city_data = OpenWeatherMapClient().get_city_weather_data(city_name)
    if not city_data:
        return {
            'headers': headers,
            'statusCode': 500,
            'body': 'Our server experienced an unexpected error. Please try again later.'
        }

    return {
        'headers': headers,
        'statusCode': 200,
        'body': json.dumps(city_data)
    }


class OpenWeatherMapClient:
    def __init__(self):
        self.BASE_URL = os.environ.get('OWM_BASE_URL')
        self.UNITS = 'metric'
        self.APP_ID = os.environ.get('OWM_APP_ID')
        self.DEFAULT_EXTERNAL_SERVICE_TIMEOUT = 4

        self.CURRENT_WEATHER_ENDPOINT = os.path.join(
            self.BASE_URL, 'data/2.5/weather',
            '&'.join(['?q={city_name}', f'units={self.UNITS}', f'appid={self.APP_ID}'])
        )
        # todo: other endpoints here

    def get_city_weather_data(self, city_name: str) -> Optional[dict]:
        url = self.CURRENT_WEATHER_ENDPOINT.format(city_name=city_name)
        # todo: handle 4**, 5** here
        with request.urlopen(
                url=url,
                timeout=self.DEFAULT_EXTERNAL_SERVICE_TIMEOUT
        ) as resp:
            return self._parse_current_weather_endpoint_data(resp.read())

    @staticmethod
    def _parse_current_weather_endpoint_data(raw_content: str) -> Optional[dict]:
        """
        Parses the response body from the `current weather` endpoint and if successful returns the
        critical fields as
        :param raw_content: str
        :type raw_content: str
        :return: Current wather temperature and feel
        :rtype: Optional[dict]
        """

        try:
            response_decoded = json.loads(raw_content)
        except (json.JSONDecodeError, TypeError) as ex:
            print('Failed to decode content:', ex)
            return None
        if not isinstance(response_decoded, dict):
            return None

        # todo: a marshmallow schema would be prettier here
        temperature = (response_decoded.get('main') or {}).get('temp')
        w = response_decoded.get('weather')
        description = w[0].get('description') \
            if w and isinstance(w, list) and isinstance(w[0], dict) else None

        return {
            'current_temperature': temperature,
            'status': description,
            'verbose': f'It\'s {description} today and about {temperature}°C',
        }
