from unittest.mock import patch

import pytest

from api.potato_cities_get import OpenWeatherMapClient


@pytest.mark.parametrize(
    'city_name,expected_raw',
    [
        (
            'cluj-napoca',
            "{'main': {'temp': 28.71}}"
        ),
        (
            'visaginas',
            "{'main': {'temp': 21.05}}"
        ),
        (
            'vilnius',
            "{'main': {'temp': 29 ..."  # <<-- malformed json
        ),
    ]
)
@patch('api.potato_cities_get.request.urlopen')
def test_get_city_weather_data(mock_urlopen, city_name, expected_raw):
    mock_urlopen.return_value.read.return_value = expected_raw
    owm_client = OpenWeatherMapClient()
    assert owm_client.get_city_weather_data(city_name) == \
           owm_client._parse_current_weather_endpoint_data(expected_raw)
