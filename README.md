![ClearPeaks Logo](https://www.clearpeaks.com/wp-content/uploads/2017/08/Clearpeaks-logo_smaller-1.svg)

# Anaconda Enterprise stress test

In one of our projects, our client had Anaconda Enterprise built on top of a Hortonworks Data Platform cluster.
One of our taks in the project, was to stress test the Anaconda platform to assure good performance with multiple concurrent users.

We developed this bash script that levarages ae5 command lines to emulate the user process:

- Create a project
- Create a new session
- Stop the session
- Delete the project

All these steps are done asynchronously to emulate the user behaviour and concurrency.

The script allows to perform all the steps both synchronously and asynchronously, and monitor the kubernetes pods.

## Run

Remember this is intended to be for an Anaconda Enterprise environment.

You will need installed [Anaconda Enterprise tools](https://github.com/Anaconda-Platform/ae5-tools).

To run the script, simply execute:

```bash
ae_stresstest [N]
```

Where N is the number of projects to create, if not specified N=25. If you select the Monitor option, N is irrelevant.

# About ClearPeaks

You can read more about us in our [website](https://www.clearpeaks.com/) were you will be able to see what [services](https://www.clearpeaks.com/bi-services/) we are offering, the [solutions](https://www.clearpeaks.com/bi-solutions-analytic-applications/) we are currently deliverying, and you will be able to read a vast of [blogs](https://www.clearpeaks.com/cp_blog/) where we discuss about many Big Data and BI topics and technologies. Furthermore, you can check our [GitHub](https://github.com/ClearPeaksSL) where we sometimes share with the community some interesting content.
