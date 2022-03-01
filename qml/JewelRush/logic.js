var jewelComponent;
var jewel1;
var jewel2;

var leftEvent;
var rightEvent;
var downEvent;
var rotateEvent;

var boardArray;
var animateDelay;

function initialise()
{
    jewelComponent = Qt.createComponent("Jewel.qml");
    leftEvent = false;
    rightEvent = false;
    downEvent = false;
    rotateEvent = false;
    boardArray = createArray(6, 12);
    animateDelay = 0;

    gameBoard.nextJewel1Color = pickColour();
    gameBoard.nextJewel1Type = pickBomb();
    gameBoard.nextJewel2Color = pickColour();
    gameBoard.nextJewel2Type = pickBomb();
}

function cmdStartNewGame()
{
    gameState = "STARTING"
    startingAnimation.start();
    desaturate.desaturation = 0;
    gameBoard.score = 0;
    gameBoard.level = 1;

    leftEvent = false;
    rightEvent = false;
    downEvent = false;
    rotateEvent = false;

    clearBoard();
    clearBoardArray();
    delete jewel1;
    delete jewel2;
    gameBoard.nextJewel1Color = pickColour();
    gameBoard.nextJewel1Type = pickBomb();
    gameBoard.nextJewel2Color = pickColour();
    gameBoard.nextJewel2Type = pickBomb();
}

function cmdRunning()
{
    gameState = "RUNNING"
    music.seek(0);
    music.play();
}

function cmdEndGame()
{

}

function cmdPause()
{
    gameState = "PAUSED"
    gameBoard.slideMessage("Paused");
    desaturate.desaturation = 1;
    music.pause();
}

function cmdResume()
{
    gameState = "RUNNING"
    gameBoard.slideMessage("Resumed");
    desaturate.desaturation = 0;
    music.play();
}

function cmdDead() {
    if (gameState !== "DEAD") {
        gameState = "DEAD";
        desaturate.desaturation = 1;

        music.stop();
        playSoundEffect("sad");
        gameBoard.slideMessage("Game Over");

        gameBoard.dead();
    }
}


function mainEvent() {
    if (gameState === "RUNNING") {
        gameBoard.mainTicks++;

        if (animateDelay > 0)  {
            animateDelay--;
            return;
        }

        //console.log(gameBoard.mainTicks, gameBoard.jewelEvent);
        if (gameBoard.mainTicks >= gameBoard.jewelEvent) {
            gameBoard.mainTicks = 0;
            checkAllLanded();
            moveJewels();
        } else {
            handleUserInput();
        }



        if (!checkFalling() && /*!jewelsMoving()*/ animateDelay === 0) {
            explodeCheck();

            if (checkIfDead()) {
                cmdDead();
            } else {
                dropNewJewels();
            }
        }


    }
}

function jewelsMoving()
{
    var moving = false;
    var jewel;
    for (var i = 0; i < board.children.length; ++i) {
        jewel = board.children[i];
        if (jewel.moving || jewel.exploding) {
            moving = true;
            break;
        }
    }

    return moving;
}

function scheduleJewelEvent() {
    //jewelEvent = !leftEvent && !rightEvent && !downEvent && !rotateEvent;
}

function scheduleLeftEvent() {
    leftEvent = !rightEvent && !downEvent && !rotateEvent;
}

function scheduleRightEvent() {
    rightEvent = !leftEvent && !downEvent && !rotateEvent;
}

function scheduleDownEvent() {
    downEvent = !leftEvent && !rightEvent && !rotateEvent;
}

function scheduleRotateEvent() {
    rotateEvent = !leftEvent && !rightEvent && !downEvent;
}

function handleUserInput() {
    if (leftEvent) {
        leftPressed()
        leftEvent = false;
        return;
    }

    if (rightEvent) {
        rightPressed()
        rightEvent = false;
        return;
    }

    if (downEvent) {
        downPressed()
        downEvent = false;
        return;
    }

    if (rotateEvent) {
        spacePressed();
        rotateEvent = false;
        return;
    }
}

function moveJewels()
{
    //debugPrintBoard();
    if (jewel1 === undefined) {
        return;
    }
    if (jewel1.falling) {
        moveJewel(jewel1, jewel1.xpos, jewel1.ypos + 1);
    }
    if (jewel2.falling) {
        moveJewel(jewel2, jewel2.xpos, jewel2.ypos + 1);
    }
    //debugPrintBoard();
}

function dropNewJewels()
{
    jewel1 = jewelComponent.createObject(board, {"xpos": 2, "ypos": -1, "falling": true, "color" : gameBoard.nextJewel1Color, "bomb" : gameBoard.nextJewel1Type});
    jewel2 = jewelComponent.createObject(board, {"xpos": 2, "ypos": -2, "falling": true, "color" : gameBoard.nextJewel2Color, "bomb" : gameBoard.nextJewel2Type});

    gameBoard.nextJewel1Color = pickColour();
    gameBoard.nextJewel1Type = pickBomb();
    gameBoard.nextJewel2Color = pickColour();
    gameBoard.nextJewel2Type = pickBomb();

}

function checkAllLanded()
{
    if (jewel1 === undefined || jewel2 === undefined) {
        return;
    }

    if (jewel1.xpos === jewel2.xpos) { //On top of each other
        if (jewel2.ypos > jewel1.ypos) {
            jewel2.falling = !checkLanded(jewel2.xpos, jewel2.ypos);
            jewel1.falling = !checkLanded(jewel1.xpos, jewel1.ypos);
        } else {
            jewel1.falling = !checkLanded(jewel1.xpos, jewel1.ypos);
            jewel2.falling = !checkLanded(jewel2.xpos, jewel2.ypos);
        }
    } else {
        jewel1.falling = !checkLanded(jewel1.xpos, jewel1.ypos);
        jewel2.falling = !checkLanded(jewel2.xpos, jewel2.ypos);
    }
    if (!jewel1.falling || !jewel2.falling) {
        downPressed();
    }
}

function checkLanded(xpos, ypos)
{
    if (ypos === 11 || blockBelow(xpos, ypos)) {
        return true;
    }
    return false;
}

function checkFalling() {
    return (jewel1 !== undefined && jewel1.falling) || (jewel2 !== undefined && jewel2.falling);
}

function leftPressed()
{
    if (jewel1 === undefined || jewel2 === undefined) {
        return;
    }

    if (!jewel1.falling || !jewel2.falling) {
        return;
    }

    if (jewel1.ypos === jewel2.ypos) { //in same row
        var minx = jewel1.xpos < jewel2.xpos ? jewel1.xpos : jewel2.xpos;
        if (minx > 0 && !isJewelAtPosition(minx - 1, jewel1.ypos)) { //can move
            playSoundEffect("rotate");

            moveJewel(jewel1, jewel1.xpos-1, jewel1.ypos);
            moveJewel(jewel2, jewel2.xpos-1, jewel2.ypos);

        }
    } else { // in same column
        if (jewel1.xpos > 0 && !isJewelAtPosition(jewel1.xpos - 1, jewel1.ypos) && !isJewelAtPosition(jewel2.xpos - 1, jewel2.ypos)) { //can move
            playSoundEffect("rotate");

            moveJewel(jewel1, jewel1.xpos-1, jewel1.ypos);
            moveJewel(jewel2, jewel2.xpos-1, jewel2.ypos);
        }
    }
}

function spacePressed()
{
    var pos2 = positionOfJewel2();

    if (!jewel1.falling || !jewel2.falling) {
        return;
    }

    switch(pos2) {
    case 1: //Jewel 2 above
        if (!isJewelAtPosition(jewel2.xpos + 1, jewel2.ypos) && !isJewelAtPosition(jewel2.xpos + 1, jewel2.ypos + 1)) {
            moveJewel(jewel2, jewel2.xpos + 1, jewel2.ypos + 1);
            playSoundEffect("rotate");
        } else if (!isJewelAtPosition(jewel1.xpos - 1, jewel1.ypos)) {
            moveJewel(jewel2, jewel1.xpos, jewel1.ypos);
            moveJewel(jewel1, jewel2.xpos - 1, jewel1.ypos);
            playSoundEffect("rotate");
        }
        break;
    case 2: //Jewel 2 right
        if (!isJewelAtPosition(jewel2.xpos, jewel2.ypos + 1) && !isJewelAtPosition(jewel2.xpos - 1, jewel2.ypos + 1)) {
            moveJewel(jewel2, jewel2.xpos - 1, jewel2.ypos + 1);
            playSoundEffect("rotate");

        }
        break;
    case 3: //Jewel 2 below
        if (!isJewelAtPosition(jewel2.xpos - 1, jewel2.ypos) && !isJewelAtPosition(jewel2.xpos - 1, jewel2.ypos - 1)) {
            moveJewel(jewel2, jewel2.xpos - 1, jewel2.ypos - 1);
            playSoundEffect("rotate");
        } else if (!isJewelAtPosition(jewel1.xpos + 1, jewel1.ypos)) {
            moveJewel(jewel2, jewel1.xpos, jewel1.ypos);
            moveJewel(jewel1, jewel2.xpos + 1, jewel1.ypos);
            playSoundEffect("rotate");

        }
        break;
    case 4: //Jewel 2 left
        if (!isJewelAtPosition(jewel2.xpos, jewel2.ypos - 1) && !isJewelAtPosition(jewel2.xpos + 1, jewel2.ypos - 1)) {
            moveJewel(jewel2, jewel2.xpos + 1, jewel2.ypos - 1)
            playSoundEffect("rotate");

        }
        break;
    default:

    }
}

function rightPressed()
{
    if (jewel1 === undefined || jewel2 === undefined) {
        return;
    }

    if (!jewel1.falling || !jewel2.falling) {
        return;
    }

    if (jewel1.ypos === jewel2.ypos) { //in same row
        var maxx = jewel1.xpos > jewel2.xpos ? jewel1.xpos : jewel2.xpos;
        if (maxx < 5 && !isJewelAtPosition(maxx + 1, jewel1.ypos)) { //can move
            playSoundEffect("rotate");

            moveJewel(jewel1, jewel1.xpos+1, jewel1.ypos);
            moveJewel(jewel2, jewel2.xpos+1, jewel2.ypos);
        }
    } else { // in same column
        if (jewel1.xpos < 5 && !isJewelAtPosition(jewel1.xpos + 1, jewel1.ypos) && !isJewelAtPosition(jewel2.xpos + 1, jewel2.ypos)) { //can move
            playSoundEffect("rotate");

            moveJewel(jewel1, jewel1.xpos+1, jewel1.ypos);
            moveJewel(jewel2, jewel2.xpos+1, jewel2.ypos);
        }
    }
}

function downPressed()
{
    if (jewel1 === undefined || jewel2 === undefined) {
        return;
    }

    var dropPos = 0;
    var playThud = false;

    if (jewel1.ypos>jewel2.ypos) {
        if (jewel1.falling) {
            dropPos = dropYpos(jewel1.xpos, jewel1.ypos);
            moveJewel(jewel1, jewel1.xpos, dropPos);
            jewel1.falling = false;
            playThud = true;
        }
        if (jewel2.falling) {
            dropPos = dropYpos(jewel2.xpos, jewel2.ypos);
            moveJewel(jewel2, jewel2.xpos, dropPos);
            jewel2.falling = false;
            playThud = true;
        }
    } else {
        if (jewel2.falling) {
            dropPos = dropYpos(jewel2.xpos, jewel2.ypos);
            moveJewel(jewel2, jewel2.xpos, dropPos);
            jewel2.falling = false;
            playThud = true;
        }
        if (jewel1.falling) {
            dropPos = dropYpos(jewel1.xpos, jewel1.ypos);
            moveJewel(jewel1, jewel1.xpos, dropPos);
            jewel1.falling = false;
            playThud = true;
        }
    }

    if (playThud) {
        playSoundEffect("thud");
    }
}

function dropYpos(xpos, ypos)
{
    //console.time("dropYpos");
    var jewel;
    var highestY = 12;
    for (var i = ypos + 1; i < 12; i++ ) {
        jewel = boardArray[xpos][i];
        if (!(jewel === undefined)) {
            if (!jewel.exploding) {
                highestY = i;
                break;
            }
        }
    }
    //console.timeEnd("dropYpos");
    return highestY - 1;
}

function blockBelow(xpos, ypos)
{
    if (boardArray[xpos][ypos+1] === undefined) {
        return false;
    }
    if (boardArray[xpos][ypos+1].falling) {
        return false;
    }
    return true;
}

//Generate a random colour
function pickColour()
{
    var colour = Math.floor((Math.random()*4)+1);
    switch (colour) {
    case 1:
        return "red";
    case 2:
        return "green"
    case 3:
        return "yellow"
    default:
        return "blue"
    }
}

//Generate chance of being a bomm
//1 in 5
function pickBomb()
{
    var numBlocks = board.children.length;
    var chance = 5;

    if (numBlocks > 48) {
        chance = 3;
    } else if (numBlocks > 36) {
        chance = 4;
    }

    var b = Math.floor((Math.random()*chance)+1);
    return b == 1;
}

//Loop over each jewel
//If it is a bomb and adjacent jewels are the
//same colour then explode
function explodeCheck()
{
    var jewel;
    for (var i = 0; i < board.children.length; ++i) {
        jewel = board.children[i];

        if (!jewel.falling && jewel.bomb) {
            var explode = false;

            var j;
            if (jewel.xpos > 0 ) {
                j = jewelAtPosition(jewel.xpos - 1, jewel.ypos);
                if (!(j === undefined) && j.color === jewel.color) {
                    explode = true;
                }
            }
            if (jewel.xpos < 5 ) {
                j = jewelAtPosition(jewel.xpos + 1, jewel.ypos);
                if (!(j === undefined) && j.color === jewel.color) {
                    explode = true;
                }
            }
            if (jewel.ypos > 0 ) {
                j = jewelAtPosition(jewel.xpos, jewel.ypos - 1);
                if (!(j === undefined) && j.color === jewel.color) {
                    explode = true;
                }
            }
            if (jewel.ypos < 11 ) {
                j = jewelAtPosition(jewel.xpos, jewel.ypos + 1);
                if (!(j === undefined) && j.color === jewel.color) {
                    explode = true;
                }
            }

            if (explode) {
                playSoundEffect("explosion");
                var numExplode = 0;
                numExplode = explodeJewel(jewel.xpos, jewel.ypos, jewel.color, 0);
                gameBoard.score += Math.pow(numExplode, 2) + gameBoard.level;
                dropJewels();
            }
        }
    }
}

//Return the jewel at the specified position
function jewelAtPosition(xpos, ypos)
{
    if (xpos >= 0 && xpos < 6 && ypos >= 0 && ypos < 12) {
        return boardArray[xpos][ypos];
    }
    return undefined;
}

function isJewelAtPosition(xpos, ypos)
{
    if (xpos >= 0 && xpos < 6 && ypos >= 0 && ypos < 12) {
        return boardArray[xpos][ypos] !== undefined;
    }
    return true;
}

function explodeJewel(xpos, ypos, c, n)
{
    var j = jewelAtPosition(xpos, ypos);

    if (!(j === undefined)) {
        j.explode(true);
        animateDelay = 1;
        delete boardArray[xpos][ypos];
        boardArray[xpos][ypos] = undefined;
        n++;
    }

    j = jewelAtPosition(xpos-1, ypos);
    if (!(j === undefined) && j.color === c && !j.exploding) {
        n = explodeJewel(xpos-1, ypos, c, n);
    }
    j = jewelAtPosition(xpos+1, ypos);
    if (!(j === undefined) && j.color === c && !j.exploding) {
        n = explodeJewel(xpos+1, ypos, c, n);
    }
    j = jewelAtPosition(xpos, ypos-1);
    if (!(j === undefined) && j.color === c && !j.exploding) {
        n = explodeJewel(xpos, ypos-1, c, n);
    }
    j = jewelAtPosition(xpos, ypos + 1);
    if (!(j === undefined) && j.color === c && !j.exploding) {
        n = explodeJewel(xpos, ypos+1, c, n);
    }
    return n;

}

//Drop all jewels after an explosion
function dropJewels()
{
    var dropped = true;

    for(var j = 0; j < 10; ++j){
        dropped = false;
        for (var i = 0; i < board.children.length; ++i) {
            var jewel = board.children[i];
            var newy = dropYpos(jewel.xpos, jewel.ypos);

            if (newy > jewel.ypos && !jewel.exploding) {
                moveJewel(jewel, jewel.xpos, newy);
                dropped = true;
            }
        }
        if (!dropped) {
            return;
        }
    }
}

function checkIfDead() {
    var dead = false;
    var jewel;

    for (var i = 0; i < board.children.length; ++i) {
        jewel = board.children[i];

        if (jewel.ypos === 0) {
            dead = true;
        }
    }
    return dead;
}

function clearBoard() {
    for (var i = 0; i < board.children.length; ++i) {
        board.children[i].destroy();
    }
    jewel1 = undefined;
    jewel2 = undefined;
}

function createArray(length) {
    var arr = new Array(length || 0),
            i = length;

    if (arguments.length > 1) {
        var args = Array.prototype.slice.call(arguments, 1);
        while(i--) arr[length-1 - i] = createArray.apply(this, args);
    }

    return arr;
}

function clearBoardArray()
{
    for (var i = 0; i < 12; ++i) {
        for (var j = 0; j < 6; ++j) {
            delete boardArray[j][i];
        }
    }
}

//Actual move of a jewel after all checks done
function moveJewel(jewel, tox, toy) {
    if (jewel === undefined) {
        return;
    }
    //delete boardArray[jewel.xpos][jewel.ypos];
    boardArray[jewel.xpos][jewel.ypos] = undefined;

    jewel.xpos = tox;
    jewel.ypos = toy;
    animateDelay = 1;

    boardArray[tox][toy] = jewel;
}

//Debugging
function debugPrintBoard() {
    console.log("------------");

    for (var i = 0; i < 12; ++i) {
        console.log(jewelChar(boardArray[0][i]),jewelChar(boardArray[1][i]),jewelChar(boardArray[2][i]),jewelChar(boardArray[3][i]),jewelChar(boardArray[4][i]),jewelChar(boardArray[5][i]))
    }
}

function jewelChar(jewel) {
    var c;
    if (jewel === undefined) {
        c = "."
    } else {
        if (jewel.color === undefined) {
            console.log(jewel);
        } else {
            c = jewel.color.substring(0,1);

            if (jewel.bomb) {
                c = c.toUpperCase();
            }
        }
    }
    return c;

}

function spaceLeft()
{
    if (jewel1.xpos === jewel2.xpos) { //in same column
        return boardArray[jewel1.xpos - 1][jewel1.ypos] === undefined &&  boardArray[jewel1.xpos - 1][jewel1.ypos] === undefined;
    } else { //in same row
        if (jewel1.xpos < jewel2.xpos) {
             return boardArray[jewel1.xpos - 1][jewel1.ypos] === undefined;
        } else {
            return boardArray[jewel2.xpos - 1][jewel2.ypos] === undefined;
        }
    }
}

function spaceRight()
{
    if (jewel1.xpos === jewel2.xpos) { //in same column
        return boardArray[jewel1.xpos + 1][jewel1.ypos] === undefined &&  boardArray[jewel1.xpos + 1][jewel1.ypos] === undefined;
    } else { //in same row
        if (jewel1.xpos < jewel2.xpos) {
             return boardArray[jewel1.xpos + 1][jewel1.ypos] === undefined;
        } else {
            return boardArray[jewel2.xpos + 1][jewel2.ypos] === undefined;
        }
    }
}

function positionOfJewel2()
{
    if (jewel1.xpos === jewel2.xpos && jewel2.ypos === jewel1.ypos - 1) { //above: 1
        return 1;
    } else if (jewel1.ypos === jewel2.ypos && jewel2.xpos === jewel1.xpos + 1) { //right: 2
        return 2;
    } else if (jewel1.xpos === jewel2.xpos && jewel2.ypos === jewel1.ypos + 1) { //below: 3
        return 3;
    } else if (jewel1.ypos === jewel2.ypos && jewel2.xpos === jewel1.xpos - 1) { //left: 4
        return 4;
    } else {
        return 0; //errro
    }
}

function playSoundEffect(effect)
{
    if (PlatformID === 4 || PlatformID === 8 || PlatformID === 5) { //ANDROID/SAILFISH/DESKTOP
        if (effect === "thud") {
            sndThud.play();
            return;
        }
        if (effect === "rotate") {
            sndRotate.play();
            return;
        }
        if (effect === "explosion") {
            sndExplosion.play();
            return;
        }
        if (effect === "getready") {
            sndGetReady.play();
            return;
        }
        if (effect === "go") {
            sndGo.play();
            return;
        }
        if (effect === "sad") {
            sndSad.play();
            return;
        }
    } else { //QtAudioEngine Available
        audioengine.sounds[effect].play();
    }
}
