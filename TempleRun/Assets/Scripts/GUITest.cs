using UnityEngine;
using System.Collections;

public class GUITest : MonoBehaviour {

    public PlayerMovement playerMovement;

    bool isRunning = true;

    void OnGUI() {

        GUI.Label(new Rect(0, 350, 600, 300), playerMovement.currentOrientation.ToString());

        if (GUI.Button(new Rect(20, 40, 150, 100), "Turn left")) {
            playerMovement.TurnHeadLeft();
        }
        if (GUI.Button(new Rect(200, 40, 150, 100), "Turn right")) {
            playerMovement.TurnHeadRight();
        }

        isRunning = GUILayout.Toggle(isRunning, "isRunning");
        playerMovement.isRunning = isRunning;

        if (GUI.Button(new Rect(20, 150, 150, 100), "Jump")) {
            playerMovement.Jump(playerMovement.jumpHeight);
        }
        if (GUI.Button(new Rect(200, 150, 150, 100), "Crouch")) {
            playerMovement.Crouch();
        }
    }
}