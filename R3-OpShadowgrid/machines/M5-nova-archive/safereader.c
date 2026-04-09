/*
 * NovaTech SafeReader v1.2 — Internal Document Tool
 * Reads archived documents from the NovaTech document store.
 *
 * Security Note (from developer, 2024-08-10):
 *   "Added path validation to ensure only /opt/archive files are readable.
 *    The check verifies the string /opt/archive is present in the path."
 *
 * BUG: strstr() only checks if the substring EXISTS in the path, not that
 *      the path STARTS with it or is confined to it.
 *      Bypass: /opt/archive/../../../root/flag5.txt
 *      The string "/opt/archive" is present, but path resolves to /root/flag5.txt
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

#define APPROVED_DIR "/opt/archive"
#define BUFFER_SIZE  4096

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "NovaTech SafeReader v1.2\n");
        fprintf(stderr, "Usage: %s <document_path>\n", argv[0]);
        fprintf(stderr, "Example: %s /opt/archive/quarterly_report.txt\n", argv[0]);
        fprintf(stderr, "\nApproved directory: %s\n", APPROVED_DIR);
        return EXIT_FAILURE;
    }

    const char *path = argv[1];

    /* Security check: ensure document is in approved directory */
    if (strstr(path, APPROVED_DIR) == NULL) {
        fprintf(stderr, "[ACCESS DENIED] Document must reside in %s\n", APPROVED_DIR);
        fprintf(stderr, "Path provided: %s\n", path);
        return EXIT_FAILURE;
    }

    /* Open and display the file (runs as root via SUID) */
    FILE *fp = fopen(path, "r");
    if (fp == NULL) {
        fprintf(stderr, "[ERROR] Cannot open document '%s': %s\n", path, strerror(errno));
        return EXIT_FAILURE;
    }

    char buffer[BUFFER_SIZE];
    size_t n;
    while ((n = fread(buffer, 1, sizeof(buffer), fp)) > 0) {
        if (fwrite(buffer, 1, n, stdout) != n) {
            fclose(fp);
            fprintf(stderr, "[ERROR] Write error\n");
            return EXIT_FAILURE;
        }
    }

    fclose(fp);
    return EXIT_SUCCESS;
}
