from setuptools import setup, find_packages

__version__ = '0.1.0'


setup(
    name='potatoweather',
    version=__version__,
    packages=find_packages(where='src'),
    package_dir={'': 'src'},
    entry_points={
        'console_scripts': [
            'potatoweather = potatoweather'
        ]
    }
)
