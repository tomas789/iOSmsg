# iOSmsg

[![Build Status](https://travis-ci.org/tomas789/iOSmsg.svg?branch=master)](https://travis-ci.org/tomas789/iOSmsg)

This allows you to publish data from iOSmsg app to ROS.

![iOSmsg app preview](https://tomas789.github.io/iOSmsg/images/app_preview_small.png)

## What is iOSmsg

It is a toolkit for publishing sensor data from iOS into ROS topics. It is set of two apps - iOSmsg and iOSmsg_client (this app).

### ... and how it works

The iOS app publishes sensor data to RabbitMQ topic in JSON format. Then client app reads them and publishes them directly to ROS topic.

## How to install iOSmsg

Since this is iOS app, you have to have OS X and Xcode to be able to run this app. You don't need to be a member of Apple Developer Program (paid $99 annually). To run it just run

```bash
git clone git@github.com:tomas789/iOSmsg.git
cd iOSmsg
pod install
```

Then open file called `iOSmsg.xcworkspace` and then you can build app and run it on your device.

## How to publish data from iOSmsg as ROS topic

Check out my another app called [iOSmsg_client](https://github.com/tomas789/iOSmsg_client)

## How to receive data from iOSmsg without ROS

This app just publishes data into RabbitMQ broker. You can easily write your own client app that listens to data from RabbitMQ's exchange. Check out source code of [iOSmsg_client](https://github.com/tomas789/iOSmsg_client) for more detail information.
