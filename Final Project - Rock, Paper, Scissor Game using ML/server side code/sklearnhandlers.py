#!/usr/bin/python

from pymongo import MongoClient
import tornado.web
import tornado.websocket

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from io import BytesIO
from tornado.options import define, options

from basehandler import BaseHandler

from sklearn.neighbors import KNeighborsClassifier
from sklearn import svm

from PIL import Image
import cv2
import pickle
from bson.binary import Binary
import json
import base64
import numpy as np
import threading
import io
import matplotlib.image as mpimg
from keras.models import load_model

clients = {}
userNames = {}
gameNames = {}

tournamentClients = {}
tournamentUserNames = {}
tournamentGameNames = {}


ML_model = None
ML_id_to_label = None


# locall host, default port
db = MongoClient(serverSelectionTimeoutMS=10).sklearndatabase # database with labeledinstances, models


# deletes all documents from the collection, resets the database
class ResetDatabase(BaseHandler):
    def get(self):
        db.clients.remove({})
        db.games.remove({})
        db.tournaments.remove({})

        self.write({"status": "success", "message": "deleted all clients & games"})


# when user Registers in the app for the firdt time
class RegisterNewCLient(BaseHandler):
    def post(self):
        data = json.loads(self.request.body.decode("utf-8"))
        print(data)
        if db.clients.find({'userName': data['userName']}).count() == 0:
            db.clients.insert({
                "userName": data['userName'],
                "gameName": data['gameName'],
                "password": data['password'],
                "steps": data['step'],          # coins earned from walking the steps of previous day
                "earnedCoins": 2000,
                "stepDate": data['stepDate']    # to ensure we don't add additional coins for the user, checking last updated date..
            })
            self.write({
                "status": "success",
                "coins": data['step'] + 2000,
                "gameName": data['gameName'],
            })
        else:
            self.write({"status": "failure", "message": "userName already exists"})

class SignIn(BaseHandler):
    def post(self):
        data = json.loads(self.request.body.decode("utf-8"))
        print(data)
        dict = db.clients.find_one({'userName': data['userName'],'password':data['password']})
        if len(dict) != 0:
            self.write({
                "status": "success",
                "coins": data['step'] + dict['earnedCoins'],
                "gameName": dict['gameName'],
            })
        else:
            self.write({"status": "failure", "message": "userName or password incorrect"})


# updates profile of the user
class UpdateClientInfo(BaseHandler):
    def post(self):
        data = json.loads(self.request.body.decode("utf-8"))
        client = db.models.update_one({"userName": data['userName']}, {"$set": {
            "gameName": data['gameName'],
            "password": data['password']
        }})
        if client is None:
            self.write({"status": "failure", "message": "no such username found"})
        else:
            self.write({"status": "success", "message": "infomation successfully updated"})

# print the handlers
class PrintHandlers(BaseHandler):
    def get(self):
        '''Write out to screen the handlers used
        This is a nice debugging example!
        '''
        self.set_header("Content-Type", "application/json")
        self.write(self.application.handlers_string.replace('),', '),\n'))

# predicts the label for rock-paper-scissor
class PredictOneFromDatasetId(BaseHandler):

    # converts base 64 string to image
    def readb64(self, base64_string):
        sbuf = BytesIO()
        sbuf.write(base64.b64decode(base64_string))
        pimg = Image.open(sbuf)
        pimg = cv2.cvtColor(np.array(pimg), cv2.COLOR_RGB2BGR)
        return cv2.resize(pimg, (100, 100))


    def predict(self):
        data = json.loads(self.request.body.decode("utf-8"))

        img = self.readb64(data['feature'])

        

        f = np.array(img)
        f = f / 255
        f = np.expand_dims(f, axis=0)

        dsid = data['dsid']

        global ML_model
        global ML_id_to_label
        # load the model from the database (using load_model)
        if ML_model is None:
            print('Loading Model From DB')
            tmp = db.models.find_one({"dsid": dsid})
            model_name = tmp['model']
            ML_model = load_model(model_name)

        if ML_id_to_label is None:
            print('Loading id_to_label From DB')
            tmp = db.models.find_one({"dsid": dsid})
            id_to_label = tmp['id_to_label']
            ML_id_to_label = {int(k): v for k, v in id_to_label.items()}

        preddiction_one_hot = ML_model.predict(f, batch_size=1, verbose=0)
        print("preddiction one hot encoded: ",preddiction_one_hot)
        predLabel = ML_id_to_label[np.argmax(preddiction_one_hot, axis=None, out=None)]

        print("Predicted Label = %s" % predLabel)
        self.write_json({"prediction": str(predLabel)})
        self.finish()


    # this annotation helps us manually call the finish functions, so we call it after we are ready to write the data back to the client
    @tornado.web.asynchronous
    def post(self):
        '''Predict the class of a sent feature vector
        '''
        self.predict()



class WSHandler(tornado.websocket.WebSocketHandler):

    #load the model when user enters game mode
    def setupDatabase(self):
        global ML_model
        global ML_id_to_label
        # load the model from the database (using load+model)
        # we are blocking tornado!! no!!
        if ML_model is None:
            print('Loading Model From DB')
            tmp = db.models.find_one({"dsid": 50})
            model_name = tmp['model']
            ML_model = load_model(model_name)

        if ML_id_to_label is None:
            print('Loading id_to_label From DB')
            tmp = db.models.find_one({"dsid": 50})
            id_to_label = tmp['id_to_label']
            ML_id_to_label = {int(k): v for k, v in id_to_label.items()}

    # updates game label when user submits a move, & returns the updated label back to all players
    def updateLabels(self,game,data):

        
        player = data['userName']
        round = game['rounds'][data['round']]

        # update round
        json_data = {}
        json_data[player] = data['label']
        game['rounds'][data['round']].update(json_data)
        round = game['rounds'][data['round']]

        # if user has yet to make a move for a round
        if list(round.values())[0] == "pending" or list(round.values())[1] == "pending":
            return game
        # if same labels were played
        elif list(round.values())[0] == list(round.values())[1]:
            round['result'] = "draw"

        # assign player 1's username in 'winner' key if he wins the round
        elif (list(round.values())[0] == "Rock" and list(round.values())[1] == "Scissor") or (list(round.values())[0] == "Paper" and list(round.values())[1] == "Rock") or (list(round.values())[0] == "Scissor" and list(round.values())[1] == "Paper") :
            round['result'] = list(round.keys())[0]

        # assign player 2's username in 'winner' key if he wins the round
        else:
            round['result'] = list(round.keys())[1]

        # updates points of players & if check if he wins the game or not, declare winner if he does..
        game['rounds'][data['round']].update(round)
        for i in range(len(game['players'])):
            player = game['players'][i]
            if player['userName'] == round['result']:
                player['points'] = player.get('points') + 1
                game['players'][i].update(player)
                if player['points'] == 3 : 
                    json_data = {}
                    json_data['winner'] = round['result']
                    game.update(json_data)

        # after 5 rounds check for winner
        if (data['round'] >= 4) and (game['winner']=="pending" or game['winner']=="draw"):
            if game['players'][0].get('points') < game['players'][1].get('points'):
                json_data = {}
                json_data['winner'] = game['players'][1]['userName']
                game.update(json_data)
            elif game['players'][1].get('points') < game['players'][0].get('points'):
                json_data = {}
                json_data['winner'] = game['players'][0]['userName']
                game.update(json_data)
            # draw, tie- breaker round
            else:
                json_data = {}
                json_data['winner'] = "draw"
                round = game['rounds'][5]
                for row in round.keys():
                    round[row] = "pending"
                game['rounds'][5].update(round)
                game.update(json_data)
        print(json.dumps(game))
        return game

    # when players submits a round move
    def gameMove(self, data):
        # update socket datas
        clients[data['userName']] = self
        userNames[self] = data['userName']

        myquery = {"gameId": data['gameId']}
       
        game = db.games.find_one(myquery, {'_id': False})
        game = self.updateLabels(game,data)
        db.games.update_one({"gameId": data['gameId']},{"$set": game})
        
        game['task'] = "gameSummary"
        print(json.dumps(game))

        # update all clients
        for player in game['players']:
            try:
                clients[player['userName']].write_message(json.dumps(game))
            except:
                print(" Old client does not exist ")

    # sends available players ready for a challenge
    def sendUpdatedPlayersList(self):
        for client in clients.values():
            players = []
            for gameName, userName in zip(gameNames.values(), userNames.values()):
                if userNames[client] != userName:
                    json_data = {'gameName': gameName, 'userName': userName}
                    players.append(json_data)

            # final json
            final = {'task': "playerList", 'players': players}
            print("2 player =====", json.dumps(final))
            try:
                client.write_message(json.dumps(final))
            except:
                print(" Old client does not exist ")

    # new player enetered 2 player mode
    def enterGame(self, data):
        print("2 player =====")

        # update all socket datas
        clients[data['userName']] = self
        gameNames[data['userName']] = data['gameName']
        for key, value in userNames.copy().items():
            count = 0
            if value == data['userName']:
                del userNames[key]
                print("value  = ",value)
                count +=1
        userNames[self] = data['userName']

        self.sendUpdatedPlayersList()
        self.setupDatabase()

    # update tournament labels
    def updateTournamentLabels(self, data):
       
        myquery = {"tournamentId" : data['tournamentId']}
        tournament = db.tournaments.find_one(myquery, {'_id': False})

        game = tournament['games'][data['gameId']]
        round = game['rounds'][data['round']]
        player = data['userName']

        # update round
        json_data = {}
        json_data[player] = data['label']

        game['rounds'][data['round']].update(json_data)
        tournament['games'][data['gameId']].update(game)
        round = game['rounds'][data['round']]
        db.tournaments.update_one({"tournamentId": data['tournamentId']},{"$set": tournament})

        #if result of round still pending
        if list(round.values())[0] == "pending" or list(round.values())[1] == "pending":
            return tournament
        # round draw
        elif list(round.values())[0] == list(round.values())[1]:
            round['result'] = "draw"

        # player 1 wins
        elif (list(round.values())[0] == "Rock" and list(round.values())[1] == "Scissor") or (list(round.values())[0] == "Paper" and list(round.values())[1] == "Rock") or (list(round.values())[0] == "Scissor" and list(round.values())[1] == "Paper") :
            round['result'] = list(round.keys())[0]
        # player 2 wins
        else:
            round['result'] = list(round.keys())[1]

        # update tournamnet docuemtns when a round result is declared
        game['rounds'][data['round']].update(round)
        tournament['games'][data['gameId']].update(game)
        for i in range(len(game['players'])):
            player = game['players'][i]
            if player['userName'] == round['result']:
                player['points'] = player.get('points') + 1
                game['players'][i].update(player)
                tournament['games'][data['gameId']].update(game)
                if player['points'] == 3 : 
                    json_data = {}
                    json_data['winner'] = round['result']
                    game.update(json_data)
                    tournament['games'][data['gameId']].update(game)

        # after 5 rounds check for winner
        if (data['round'] >= 4) and (game['winner']=="pending" or game['winner']=="draw"):
            if game['players'][0].get('points') < game['players'][1].get('points'):
                json_data = {}
                json_data['winner'] = game['players'][1]['userName']
                game.update(json_data)
            elif game['players'][1].get('points') < game['players'][0].get('points'):
                json_data = {}
                json_data['winner'] = game['players'][0]['userName']
                game.update(json_data)
            # draw
            else:
                json_data = {}
                json_data['winner'] = "draw"
                round = game['rounds'][5]
                for row in round.keys():
                    round[row] = "pending"
                game['rounds'][5].update(round)
                game.update(json_data)
                
        # get winner of quater finals player's data
        current_winner = tournament['games'][data['gameId']]['winner']
        for player in tournament['games'][data['gameId']]['players'] :
            if player['userName'] == current_winner:
                player_data = player
                player_data['points'] = 0

        # assign winner of quater finals 1 to semi finals players list
        if data['gameId'] == 0:
            
            next_game = tournament['games'][4]
            player = next_game['players'][0]
            if current_winner != "pending" and current_winner != "draw":
                del next_game['players'][0]
                next_game['players'].append(player_data)
                
                for round in next_game['rounds']:
                    del round['pending1']
                    round[current_winner] = "pending"
                    
                
            next_game['players'][0] = player
            tournament['games'][4].update(next_game)

        # assign winner of quater finals 2 to semi finals players list        
        elif data['gameId'] == 1:
            
            next_game = tournament['games'][4]
            player = next_game['players'][1]
            if current_winner != "pending" and current_winner != "draw":
                del next_game['players'][1]
                next_game['players'].append(player_data)
                
                for round in next_game['rounds']:
                    del round['pending2']
                    round[current_winner] = "pending"
            next_game['players'][1] = player
            tournament['games'][4].update(next_game)

        # assign winner of quater finals 3 to semi finals players list
        elif data['gameId'] == 2:
            
            next_game = tournament['games'][5]
            player = next_game['players'][0]
            if current_winner != "pending" and current_winner != "draw":
                del next_game['players'][0]
                next_game['players'].append(player_data)
                
                for round in next_game['rounds']:
                    del round['pending1']
                    round[current_winner] = "pending"
            next_game['players'][0] = player
            tournament['games'][5].update(next_game)

        # assign winner of quater finals 4 to semi finals players list
        elif data['gameId'] == 3:                
            next_game = tournament['games'][5]
            player = next_game['players'][1]
            if current_winner != "pending" and current_winner != "draw":
                del next_game['players'][1]
                next_game['players'].append(player_data)
                
                for round in next_game['rounds']:
                    del round['pending2']
                    round[current_winner] = "pending"
            next_game['players'][1] = player
            tournament['games'][5].update(next_game)

        # assign winner of semi finals 1 to finals players list
        elif data['gameId'] == 4:
            current_winner = tournament['games'][data['GameId']]['winner']
            next_game = tournament['games'][6]
            player = next_game['players'][0]
            if current_winner != "pending" and current_winner != "draw":
                del next_game['players'][0]
                next_game['players'].append(player_data)
                
                for round in next_game['rounds']:
                    del round['pending1']
                    round[current_winner] = "pending"
            next_game['players'][0] = player
            tournament['games'][6].update(next_game)

        # assign winner of semi finals 2 to finals players list
        elif data['gameId'] == 5:
            current_winner = tournament['games'][data['GameId']]['winner']
            next_game = tournament['games'][6]
            player = next_game['players'][1]
            if current_winner != "pending" and current_winner != "draw":
                del next_game['players'][1]
                next_game['players'].append(player_data)
                
                for round in next_game['rounds']:
                    del round['pending2']
                    round[current_winner] = "pending"
            next_game['players'][1] = player
            tournament['games'][6].update(next_game)
       
        tournament['task'] = "tournamentSummary"
        tournament['games'][data['gameId']].update(game)
        print(tournament)
        db.tournaments.update_one({"tournamentId": data['tournamentId']},{"$set": tournament})
        return tournament

    def tournamentGameMove(self, data):
        # update socket data
        tournamentClients[data['userName']] = self
        tournamentUserNames[self] = data['userName']

        tournament = self.updateTournamentLabels(data)

        # write all clients
        for player in tournamentClients.values():
            try:
                player.write_message(tournament)
            except:
                print(" Old client does not exist ")

    # draft an initial tournament json & save it in db, write to all clients
    def initialTournamentLabels(self):
        final = {}
    
        count = db.tournaments.find().count()
        #count = 0
        games = []
        for i in range(7):
            if i<4:
                rounds = []
                for j in range(6):
                    json_data = {}
                    json_data[list(tournamentUserNames.values())[i*2+1]] = "pending"
                    json_data[list(tournamentUserNames.values())[i*2]] = "pending"
                    json_data["result"] = "pending"
                    rounds.append(json_data)
                game = {
                "gameId":i,
                "winner":"pending",
                "players": [
                     {
                         "gameName": list(tournamentGameNames.values())[i*2],
                         "userName": list(tournamentUserNames.values())[i*2],
                         "points": 0
                     },
                     {
                         "gameName": list(tournamentGameNames.values())[i*2+1],
                         "userName": list(tournamentUserNames.values())[i*2+1],
                         "points": 0
                     }],
                "rounds":rounds
                }
            else:
                rounds = []
                for j in range(6):
                    json_data = {}
                    json_data["pending1"] = "pending"
                    json_data["pending2"] = "pending"
                    json_data["result"] = "pending"
                    rounds.append(json_data)
                game = {
                "gameId":i,
                "winner":"pending",
                "players": [
                     {
                         "gameName": "pending",
                         "userName": "pending",
                         "points": 0
                     },
                     {
                         "gameName": "pending",
                         "userName": "pending",
                         "points": 0
                     }],
                "rounds":rounds
                }
            games.append(game)
        final = {'task': "tournamentSummary", 'tournamentId': count,'games':games}
        
        return json.dumps(final)

    # sends updated tournament players list ot all other players
    def sendUpdatedTournamentPlayersList(self):

        # tournament starts
        if len(tournamentUserNames) == 8  :
                final = self.initialTournamentLabels()
                db.tournaments.insert(json.loads(final))
        else:
                players = []
                for gameName, userName in zip(tournamentGameNames.values(), tournamentUserNames.values()):
                    json_data = {'gameName': gameName, 'userName': userName}
                    players.append(json_data)
                # final json
                final = {'task': "tournamentPlayerList", 'players': players}

        print(final)
        for client in tournamentClients.values():
            try:
                client.write_message(final)
            except:
                print(" Old client does not exist ")

    # when player enters tournament
    def enterTournamentGame(self, data):
        # update socket datas
        tournamentClients[data['userName']] = self
        tournamentGameNames[data['userName']] = data['gameName']
        for key, value in tournamentUserNames.copy().items():
            count = 0
            if value == data['userName']:
                del tournamentUserNames[key]
                print("value  = ",value)
                count +=1
        tournamentUserNames[self] = data['userName']

        print("enterd : ", tournamentClients)
        print("enterd : ", tournamentGameNames)
        print("enterd : ", tournamentUserNames)

        if data['tournamentId'] == -1:
            self.sendUpdatedTournamentPlayersList()
        else:
            myquery = {"tournamentId" : data['tournamentId']}
            tournament = db.tournaments.find_one(myquery, {'_id': False})
            self.write_message(json.dumps(tournament))



    # challange opponent for a 2 player match
    def challengeOpponent(self, data):
        current_userName = data['userName']
        opponent = data['opponent']

        # challenge opponent json
        json_data = {'task': "opponentRespond", 'gameName': gameNames[current_userName], 'userName': current_userName}
        print(json_data)
        clients[opponent].write_message(json.dumps(json_data))

        # feedback to the challenger
        json_data = {'task': "challengeInvitationSent", 'message': "waiting for user"}
        print(json_data)
        self.write_message(json.dumps(json_data))

    # respond by it's opponent
    def opponentRespond(self, data):
        repsonse = data['repsonse']
        opponent = data['opponent']
        challenger = userNames[self]
        count = db.games.find().count()

        # draft a game document and save it in db if user accepts the challenge
        if repsonse == "accept":
            json_data = {}
            json_data['task'] = "replyFromOpponent"
            json_data['response'] = "accept"
            json_data['gameId'] = count
            print(json_data)
            clients[opponent].write_message(json.dumps(json_data))
            clients[challenger].write_message(json.dumps(json_data))

            rounds = []
            for i in range(6):
                json_data = {}
                json_data[opponent] = "pending"
                json_data[challenger] = "pending"
                json_data["result"] = "pending"
                rounds.append(json_data)


            db.games.insert({
                "gameId":count,
                "winner":"pending",
                "players": [
                     {
                         "gameName": gameNames[opponent],
                         "userName": opponent,
                         "points": 0
                     },
                     {
                         "gameName": gameNames[challenger],
                         "userName": challenger,
                         "points": 0
                     }],
                "rounds":rounds
            })
        else:
            json_data = {}
            json_data['task'] = "replyFromOpponent"
            json_data['response'] = "reject"
            json_data['message'] = opponent + " rejected your challange!"
            print(json_data)
            clients[opponent].write_message(json.dumps(json_data))


    def check_origin(self, origin):
        return True

    # calls every time a new socket connection is opened
    def open(self):
        print('connection opened')
        self.write_message("Echo: connection opened")

    # calls every time a socket connection is closed
    def on_close(self):

        # updates all socket datas, since client object keeps changing for every user. I added try & catch for all
        try:
            del gameNames[userNames[self]]
        except Exception as e:
            print("Exception in on_close gameNames : ")
        try:
            del clients[userNames[self]]
        except Exception as e:
            print("Exception in on_close clients: ")
        try:
            del userNames[self]
        except Exception as e:
            print("Exception in on_close userNames: ")
        self.sendUpdatedPlayersList()
        try:
            del tournamentGameNames[tournamentUserNames[self]]
        except Exception as e:
            print("Exception in on_close tournamentGameNames : ")
        try:
            del tournamentClients[tournamentUserNames[self]]
        except Exception as e:
            print("Exception in on_close tournamentClients: ")
        try:
            del tournamentUserNames[self]
        except Exception as e:
            print("Exception in on_close tournamentUserNames: ")
        self.sendUpdatedTournamentPlayersList()

    def exitGame(self,data):
        try:
            exit_userName = userNames[self]
            del userNames[self]
            if exit_userName is not None:
                del gameNames[exit_userName]
                del clients[exit_userName]
            print('connection closed for', exit_userName)
        except Exception as e:
            print("Exception in on_close : ",  str(e))

    # when client sends a message to the server
    def on_message(self, message):

        data = json.loads(message)
        print(message)

        # client message contains a task by which servers knows what to do...
        task = data['task']
        if task == "enterGame":
            self.enterGame(data)
        elif task == "exitGame":
            self.exitGame(data)
        elif task == "challengeOpponent":
            self.challengeOpponent(data)
        elif task == "opponentResponse":
            self.opponentRespond( data)
        elif task == "gameMove":
            self.gameMove(data)
        elif task == "enterTournamentGame":
            self.enterTournamentGame(data)
        elif task == "exitTournamentGame":
            self.exitTournamentGame(data)
        elif task == "tournamentGameMove":
            self.tournamentGameMove(data)


