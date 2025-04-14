# Counting Steps Widget

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

The Counting Steps Widget is an app designed to help you track your steps throughout the day. It features goal-setting functionality, allowing you to set a daily step target and monitor your progress. The app also tracks the calories you burn and includes a ranking system to compare your achievements with friends.

### App Evaluation

[Evaluation of your app across the following attributes]
- **Category:** [Fitness, Health ]
- **Mobile:** [Yes]
- **Story:**  [The Counting Steps Widget app tells the story of your fitness journey, helping you track your steps, set goals, and see the progress you make each day. It motivates you by showing calories burned and offers a ranking system to compare your achievements with friends.]
- **Market:** [Target audience for the app: Fitness Enthusiasts and Casual Exercisers]
- **Habit:** [Is it a daily use app? Yes]
- **Scope:** [Is it a broad or narrow app in terms of features? Narrow]

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users can view their steps throughout the day
* Users can see the amount of calories they burned based
* Users can set a daily goal to achieve
* Users can view their distance in miles 

**Optional Nice-to-have Stories**

* Users can see the leader board with other users activity
* Users can send chat messages to other users
* Users can see how far apart they are from another user in steps 

### 2. Screen Archetypes

- [ ] Home Widget Screen
* User can see their steps they've walked
* User can see how many calories they burned
* Users are able to see their distance in mi or km
* Users are able to see their daily goal progress
- [ ] Goal Screen
* User are able to set a goal for the day
- [ ] Leader Board 
* Users are able to see other peoples progress
* Users are able to see how far apart they are from another user
- [ ] Chat
* Users are able to sent messages to others

### 3. Navigation

**Tab Navigation** (Tab to Screen)


- [ ] Home
- [ ] Goals
- [ ] Leader board
- [ ] Chat 
...

**Flow Navigation** (Screen to Screen) ?

- [ ] Home Widget Screen
  * Leads to Goal Screen, Leader board & Chat
- [ ] Goal Screen
  * Leads to Home 
- [ ] Leader Board
  * Leads to Home
- [ ] Chat
  * Leads to Home


## Wireframes

![IMG_0517](https://github.com/user-attachments/assets/893de3ce-669f-40c8-ae4c-5c21591a4b6f)

Digital WireFrame

<img width="865" alt="Screenshot 2025-04-13 at 5 45 34 PM" src="https://github.com/user-attachments/assets/facac637-9946-4bdd-ba68-68e16ffa80f4" />

Visual Prototype 
![ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/903228bf-c34a-4f56-a323-96558d9ae2b5)


## Schema 


### Models

User
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| username | String | unique id for the user post (default field)  |
| password | String | user's password for login authentication     |
| email    | String | user's email address (optional)
| step_goal    | int | individual users step goal


Steps Tracker
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| user     | pointer| Links to the user                            |
| steps    | int    | Steps walked in the day                      |
| calories | int    | calories burned                              |
| distance | int    | distance covered (mi/km)                     |
| goal     | int    | daily step goal                              |
| date     | date   | log date                                     |



Message
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| sender   | pointer| who sent the message (user)                  |
| receiver | pointer| who is receiving the message (user)          |
| content  | string | message content                              |
| timestamp| date   | when the message was sent                    |

### Networking

- [List of network requests by screen]
- Home Widget Screen
    - [GET] /steptracker/today : fetch today's steps, distance, and calories
    - [POST] /steptracker : submit or update step data for today
- Goal Screen
    - [PUT] /steptracker/goal : update today's step goal
- Leader board Screen
    - [GET] /leaderboard : get top users and current user's ranking
    - [GET] /leaderboard/user : compare current user to others
- Chat Screen
    - [POST] /message : send a message to another user
    - [GET] /messages : get all messages for the current user
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
