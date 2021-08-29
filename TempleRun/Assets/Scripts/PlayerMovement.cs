using System.Collections;
using System.Collections.Generic;
using System.Data;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PlayerMovement : MonoBehaviour
{
    public bool isRunning = true;
    private bool turnLeft, turnRight, isGrounded;
    public float speed = 7.0f;
    private CharacterController controller;

    private Vector3 velocity;
    public float jumpHeight = 1.0f;
    private float gravityValue = -9.81f;

    private Animator anim;

    public Orientation currentOrientation;

    void Start() {
        controller = GetComponent<CharacterController>();
        anim = GetComponent<Animator>();

        currentOrientation = Orientation.CENTER;
    }
    
    public void Jump(float value){
        if (isGrounded){
            velocity.y += Mathf.Sqrt(value * -3.0f * gravityValue);
            anim.SetTrigger("Jump");
        }
    }
    
    public void Crouch(){
        if (isGrounded){
            anim.SetTrigger("Crouch");
        }
    }

    public void TurnHeadLeft() {
        if (currentOrientation == Orientation.CENTER) {
            currentOrientation = Orientation.LEFT;
            TurnLeft();
        } else if (currentOrientation == Orientation.RIGHT) {
            currentOrientation = Orientation.CENTER;
        } else {
            //nothing happens
        }
    }

    public void TurnHeadRight() {
        if (currentOrientation == Orientation.CENTER) {
            currentOrientation = Orientation.RIGHT;
            TurnRight();
        } else if (currentOrientation == Orientation.LEFT) {
            currentOrientation = Orientation.CENTER;
        } else {
            //nothing happens
        }
    }
    
    public void TurnLeft(){
        transform.Rotate(new Vector3(0f, -90f, 0f));
    }
    
    public void TurnRight(){
        transform.Rotate(new Vector3(0f, 90f, 0f));
    }

    void Update() {
        if (!isRunning) {
            EndGame();
        }

        //isGrounded = controller.isGrounded;
        isGrounded = Physics.Raycast(transform.position, Vector3.down, .24f, 1 << LayerMask.NameToLayer("Ground"));
        if (isGrounded && velocity.y < 0) {
            velocity.y = 0f;
        }

        turnLeft = Input.GetKeyDown(KeyCode.A);
        turnRight = Input.GetKeyDown(KeyCode.D);

        if (turnLeft)
            TurnLeft();
        else if (turnRight)
            TurnRight();

        controller.SimpleMove(new Vector3(0f, 0f, 0f));
        controller.Move(transform.forward * speed * Time.deltaTime);

        if (Input.GetButtonDown("Jump"))
        {
            Jump(jumpHeight);
        }

        velocity.y += gravityValue * Time.deltaTime;
        controller.Move(velocity * Time.deltaTime);

        if (Input.GetButtonDown("Crouch")) {
            Crouch();
        }
    }

    private void OnTriggerStay(Collider other) {
        //Debug.Log(other.name);
        if (other.CompareTag("Obstacle")) {
            EndGame();
        }
    }

    private void EndGame() {
        SceneManager.LoadScene(2);
    }
}

public enum Orientation {
    LEFT,
    RIGHT,
    CENTER
}
