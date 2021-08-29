using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    public Transform target;
    public float trailDistance = 5.0f;
    public float heightOffset = 3.0f;
    public float cameraDelay = 0.02f;

    private float height;

    private void Start() {
        Vector3 startPos = target.position - target.forward * trailDistance;
        startPos.y += heightOffset;
        height = startPos.y;
    }

    void Update() {
        Vector3 followPos = target.position - target.forward * trailDistance;

        followPos.y = height;
        transform.position += (followPos - transform.position) * cameraDelay;

        //transform.LookAt(target.transform);
        Vector3 targetPostition = new Vector3(target.position.x,
                                        transform.position.y,
                                        target.position.z);
        transform.LookAt(targetPostition);
    }
}
