using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnTile : MonoBehaviour
{
    public bool useTopTile;

    public List<GameObject> regTiles;
    public GameObject groundTile;
    public GameObject topTile;
    public float spawnGroundChance = .1f;
    public GameObject referenceObject;
    public float timeOffset = 0.4f;
    public float distanceBetweenTiles = 5.0F;
    public float randomValue = 0.8f;
    private Vector3 previousTilePosition;
    private Vector3 direction, mainDirection = new Vector3(0, 0, 1), otherDirection = new Vector3(1, 0, 0);

    private Queue<GameObject> spawnedTiles;
    private int tileLimit = 100;

    void Start() {
        previousTilePosition = referenceObject.transform.position;
        spawnedTiles = new Queue<GameObject>();

        StartCoroutine(Spawn());
    }

    private IEnumerator Spawn() {
        bool justSpawnedObstacle = false;

        while (true) {
            if (!justSpawnedObstacle && Random.value > randomValue) {
                Vector3 temp = direction;
                direction = otherDirection;
                mainDirection = direction;
                otherDirection = temp;
            } else {
                direction = mainDirection;
            }

            Vector3 spawnPos = previousTilePosition + distanceBetweenTiles * direction;

            GameObject toSpawn = regTiles[0];
            if (Random.value < .5f) {
                toSpawn = regTiles[Random.Range(0, regTiles.Count)];
            }

            if (!justSpawnedObstacle && Random.value < spawnGroundChance) {
                justSpawnedObstacle = true;

                if (Random.value < .5f || !useTopTile) {
                    toSpawn = groundTile;
                } else {
                    toSpawn = topTile;
                }
            } else {
                justSpawnedObstacle = false;
            }

            Quaternion rotation = direction == new Vector3(0, 0, 1) ? Quaternion.Euler(0, 90, 0) : Quaternion.Euler(0, 0, 0);

            GameObject tile = Instantiate(toSpawn, spawnPos, rotation);
            spawnedTiles.Enqueue(tile);
            previousTilePosition = spawnPos;

            if (spawnedTiles.Count > tileLimit) {
                Destroy(spawnedTiles.Dequeue());
            }

            yield return new WaitForSeconds(timeOffset);
        }
    }
}
