from setuptools import setup, find_packages

def readme():
    with open("README.md") as f:
        return f.read()

setup(
    name="psbio",
    version="0.0.1",
    description="A collection of scripts for biomedical signal processing",
    long_description=readme(),
    long_description_content_type="text/markdown",
    author="mendes-davi",
    author_email="davi.aviva(at)gmail.com",
    license="MIT",
    # scripts=['bin/foo'],
    # entry_points={
        # 'console_scripts': [ 'psbio_demo_spectrogram=psbio.demos.my_spectrogram:main' ],
    # },
    packages=find_packages(exclude=['docs']),
    install_requires=['numpy', 'matplotlib', 'scipy'],
    package_data={ 'psbio': ['datasets/*'] },
)
